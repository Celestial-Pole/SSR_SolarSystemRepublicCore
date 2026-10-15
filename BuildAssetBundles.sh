#!/usr/bin/env bash
#
# 逐个平台在批处理模式下构建 AssetBundle,输出到 Asset/{Windows,Linux,MacOS}。
#
# 为什么不在编辑器里一次构建三个平台:BuildPipeline.BuildAssetBundles 会因为目标平台
# 不同而切换 Active Build Target,而切换会重建编辑器窗口的图形上下文。在本机的
# Vulkan 编辑器上,这一步会卡在 GfxDeviceClient::WindowReshape 并最终 SIGSEGV。
# 批处理模式没有编辑器窗口,这条崩溃路径不会被触发;每个平台各启动一个 Unity 进程,
# 目标在启动时就已确定(-buildTarget),因此完全不需要切换。
#
# 用法: ./BuildAssetBundles.sh
#   可先用 UNITY_EDITOR=/path/to/Unity 指定编辑器。
set -euo pipefail

REPOSITORY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$REPOSITORY_DIR/src/SSR.UnityComponent"
METHOD="Assets.Editor.AssetBundles.BuildFromCommandLine"

if [[ -n "${UNITY_EDITOR:-}" ]]; then
  EDITOR="$UNITY_EDITOR"
else
  VERSION="$(sed -n 's/^m_EditorVersion: *//p' "$PROJECT_DIR/ProjectSettings/ProjectVersion.txt" | tr -d '\r')"
  EDITOR="$HOME/Unity/Hub/Editor/$VERSION/Editor/Unity"
fi

if [[ ! -x "$EDITOR" ]]; then
  echo "找不到 Unity 编辑器:$EDITOR" >&2
  echo "请用 UNITY_EDITOR 环境变量指定编辑器可执行文件。" >&2
  exit 1
fi

# 编辑器打开本工程时批处理会失败,提前提醒一下(崩溃后残留的锁文件无关紧要)。
if [[ -e "$PROJECT_DIR/Temp/UnityLockfile" ]]; then
  echo "提示:检测到 $PROJECT_DIR/Temp/UnityLockfile,如果编辑器正开着本工程请先关闭。" >&2
fi

for target in StandaloneWindows64 StandaloneLinux64 StandaloneOSX; do
  log="$PROJECT_DIR/Library/assetbundles-$target.log"
  echo "==> 构建 $target"
  "$EDITOR" -batchmode -nographics -quit \
    -projectPath "$PROJECT_DIR" \
    -buildTarget "$target" \
    -executeMethod "$METHOD" \
    -logFile "$log"
  echo "    日志:$log"
done

echo "==> 完成:Asset/{Windows,Linux,MacOS}"
