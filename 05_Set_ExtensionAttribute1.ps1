#######################################
#
# 作成日：2022/04/14 Ver1.0
# 更新日：2022/04/14 Ver1.1  取得する値の誤りのため
# 更新日：2022/04/19 Ver1.2  ExtensionAttribute2 を設定
# 機能    ："02_Get_ms-ds-consistencyGUID_ByHex.ps1" を実行し、出力した「mS-DS-ConsistencyGuid_ByHex.csv」を読み込み、
#           "ExtensionAttribute1"が "Sync" となっているオブジェクトの"ExtensionAttribute1"を"Sync"を設定していく
#           すでに "Sync"が入力されていてもエラーにならず、ログには"True"と出力
#           "ExtensionAttribute2"にはいっている "M365_E3" "Azure_AD_Premium_P1" となっているオブジェクトの"ExtensionAttribute2"に各値を設定する
# 実行場所：オンプレAD上にて実行
#
# 定数        ：
#
#     ◆ 読み込みファイル (項目名に "UserPrincipalNam" "mS-DS-ConsistencyGuid" は必須) ◆

          $in = "C:\temp\input\input.csv"

#     ◆ 対象となるOU ◆

          $SearchBase = "OU=People,DC=tokai,DC=tokaicarbon,DC=co,DC=jp"

#     ◆ ログファイル名出力先 ◆

          $log_fol = "C:\temp\log\"

####################################################

$formatdate = (Get-Date).ToString("yyyyMMddHHmmss")

# スクリプト名
$script = $myInvocation.MyCommand.name

$log = $log_fol + $script + "_$formatdate.log"

"$script ------------- 処理開始 -------------" > $log
Get-Date >> $log

"UserPrincipalName,msDS-cloudExtensionAttribute1_result,msDS-cloudExtensionAttribute1_result" >> $log

# CSV 読み込み (タブ区切り)
$ADUser = Import-Csv $in -Delimiter "`t"

$ubound = $ADUser.count

for($i = 0; $i -lt $ubound; $i++){

    $ret_code_1 = ""
    $ret_code_2 = ""

    if( [String]$ADUser[$i]."msDS-cloudExtensionAttribute1" -eq "Sync" ){

         Set-ADUser -Identity $ADUser[$i].ObjectGUID -add @{ "msDS-cloudExtensionAttribute1" = "Sync" }

         $ret_code_1 = $?
     }

    
    # --Ver1.2 Add--
    if( [String]$ADUser[$i]."msDS-cloudExtensionAttribute2" -ne "" ){

         Set-ADUser -Identity $ADUser[$i].ObjectGUID -add @{ "msDS-cloudExtensionAttribute2" = $ADUser[$i]."msDS-cloudExtensionAttribute2" }

         $ret_code_2 = $?

     }

         # 2022004/18 new_ を追加 --Ver1.2 Add--
         $ADUser[$i].new_UserPrincipalName + "," + $ret_code_1 + "," +  $ret_code_2 >> $log  




}

Get-Date >> $log

"$script ------------- 処理終了 -------------" >> $log

