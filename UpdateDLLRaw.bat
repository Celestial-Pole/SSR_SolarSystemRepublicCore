DEL "S:\Program Files (x86)\Steam\steamapps\common\RimWorld\Mods\SSR_Main\SoftRely\%1\AKFrameNotActive\Assemblies\AFS_UGUIFramework.dll"
COPY "C:\Users\Fleurety\Desktop\rw\SSR_Framework\Solar-System-Republic-Framework\FS_SSR\bin\Debug\FS_UGUIFramework.dll" "S:\Program Files (x86)\Steam\steamapps\common\RimWorld\Mods\SSR_Main\SoftRely\%1\AKFrameNotActive\Assemblies\"
REN "S:\Program Files (x86)\Steam\steamapps\common\RimWorld\Mods\SSR_Main\SoftRely\AKFrameNotActive\%1\Assemblies\FS_UGUIFramework.dll" "AFS_UGUIFramework.dll"

DEL "S:\Program Files (x86)\Steam\steamapps\common\RimWorld\Mods\SSR_Main\%1\Assemblies\FS_SSR.dll"
COPY "C:\Users\Fleurety\Desktop\rw\SSR_Framework\Solar-System-Republic-Framework\FS_SSR\obj\DebugV16\FS_SSR.dll" "S:\Program Files (x86)\Steam\steamapps\common\RimWorld\Mods\SSR_Main\%1\Assemblies\"

DEL "S:\Program Files (x86)\Steam\steamapps\common\RimWorld\Mods\SSR_Main\%1\Assemblies\FS_SSR_Combat.dll"
COPY C:\Users\Fleurety\Desktop\rw\SSR_Framework\Solar-System-Republic-Framework\Combat\bin\Debug\FS_SSR_Combat.dll "S:\Program Files (x86)\Steam\steamapps\common\RimWorld\Mods\SSR_Main\%1\Assemblies\"

DEL "S:\Program Files (x86)\Steam\steamapps\common\RimWorld\Mods\SSR_Main\%1\Assemblies\FS_SSR_Compatibility.dll"
COPY "C:\Users\Fleurety\Desktop\rw\SSR_Framework\Solar-System-Republic-Framework\FS_SSR_Compatibility\bin\Debug\FS_SSR_Compatibility.dll" "S:\Program Files (x86)\Steam\steamapps\common\RimWorld\Mods\SSR_Main\%1\Assemblies\"

PAUSE