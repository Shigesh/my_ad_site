
#######################################
#
# 作成日：2022/04/01  Ver1.0
# 機能："MsolUser.csv"ファイルを読み込み、UPNとImmutableIDをBase64を16進数表記に変換した値を出力する、
#
#######################################

$formatdate = (Get-Date).ToString("yyyyMMddHHmmss")

# 入力ファイル名  --Ver1.1 Add--
$in = "C:\temp\00_Get_MsolUser.ps1.log"

# スクリプト名  --Ver1.1 Add--
$script = $myInvocation.MyCommand.name


# 出力ファイル名  --Ver1.1 Mod--
$out = "C:\temp\" + $script + "_$formatdate.log"

# 列名出力
"UPN" + "`t" + "mS-DS-ConsistencyGuid" > $out

$f = (Import-CSV -delimiter "`t" -Path $in)

$lines = $f.count

for ($i = 0; $i -lt $lines; $i++){

    $Immu = $f[$i].ImmutableID
       
    # Base64をエンコードし、16進数表記に変換
    $mSDSConsistencyGuid = [System.Convert]::FromBase64String($Immu) | Format-Hex -Encoding Ascii
    
    $ImmutalbleID_Hex_Col = $mSDSConsistencyGuid -split(" ")
    
    $ImmutalbleID_Hex = $ImmutalbleID_Hex_Col[3..18] -join " "

    # UPNとmS-DS-ConsistencyGuidを出力
    $f[$i].UserPrincipalName + "`t" + $ImmutalbleID_Hex >> $out

}
