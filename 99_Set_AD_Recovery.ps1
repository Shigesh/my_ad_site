#######################################
#
# 作成日：2022/04/18 Ver1.0
# 機能    ：input.csv を読み込んで、new_UserPrincipalName/mS-DS-ConsistencyGuid/ExtensionAttribute1 のinput.csv
#           各項目の値が new_UserPrincipalName は、入力されている値、mS-DS-ConsistencyGuid/ExtensionAttribute1 は、空欄のみ ADの値も空欄にする ※値がセットされていてもセットはされない
# 実行場所：オンプレAD上にて実行
#
# 定数        ：
#
#     ◆ 読み込みファイル (UPN/mS-DS-ConsistencyGuid/ExtensionAttribute1 の各値に"clear"と記載されている属性値をクリアにする ) ◆

          $in = "C:\temp\input\input_r.csv"

#     ◆ 対象となるOU ◆

          $SearchBase = "OU=People,DC=tokai,DC=tokaicarbon,DC=co,DC=jp"

#     ◆ ログファイル名出力先 ◆

          $log_fol = "C:\temp\log\"
# 作業前の一覧
$old_list = $log_fol + $script + "_$formatdate" + "_list_old.csv"

# 作業後の一覧
$new_list = $log_fol + $script + "_$formatdate" + "_list_new.csv"

####################################################

$formatdate = (Get-Date).ToString("yyyyMMddHHmmss")

# スクリプト名
$script = $myInvocation.MyCommand.name

$log = $log_fol + $script + "_$formatdate.log"

# 処理最後に、一覧取得
# --Ver1.1 Mod タブ区切りで出力--
$ADUser = Get-ADUser -SearchBase $SearchBase -Filter * -Properties msDS-cloudExtensionAttribute1,msDS-cloudExtensionAttribute2,mS-DS-ConsistencyGuid

# --Ver1.1 Mod タブ区切りで出力 Ver1.2 出力ファイル名修正--
$ADUser | Export-Csv -delimiter "`t" -Encoding Default -Path $old_list
  

 

"$script ------------- 処理開始 -------------" > $log
Get-Date >> $log

"upn_result,ex_att1_result,ex_att2_result,mS_Guid_result" >> $log

# CSV 読み込み (タブ区切り)
$ADUser = Import-Csv $in -Delimiter "`t"

$ubound = $ADUser.count


for($i = 0; $i -lt $ubound; $i++){

    # $inファイルの new_UserPrincipalName の値が空欄だったらクリア、値が入っている場合はその値を入力
    if( [String]$ADUser[$i].new_UserPrincipalName -ne "" ){ 
        Set-ADUser -Identity $ADUser[$i].ObjectGUID -UserPrincipalName $ADUser[$i].new_UserPrincipalName
        $ret_code_1 = $?
    }elseif( [String]$ADUser[$i].new_UserPrincipalName -eq "" ){
        Set-ADUser -Identity $ADUser[$i].ObjectGUID -Clear UserPrincipalName
        $ret_code_1 = $?
    }else{
        $ret_code_1 = 99 
    }

    # $inファイルの msDS-cloudExtensionAttribute1 の値が空欄だったらクリア
    if( [String]$ADUser[$i]."msDS-cloudExtensionAttribute1" -eq ""){ 
        Set-ADUser -Identity $ADUser[$i].ObjectGUID -Clear msDS-cloudExtensionAttribute1
        $ret_code_2 = $?
        }



    # $inファイルの ExtensionAttribute1 の値が空欄だったらクリア
    if( [String]$ADUser[$i]."msDS-cloudExtensionAttribute2" -eq ""){ 
        Set-ADUser -Identity $ADUser[$i].ObjectGUID -Clear msDS-cloudExtensionAttribute2
        $ret_code_3 = $?
        }

    # $inファイルの mS-DS-ConsistencyGuid の値が空欄だったらクリア
    if( [String]$ADUser[$i].'mS-DS-ConsistencyGuid' -eq ""){ 
        Set-ADUser -Identity $ADUser[$i].ObjectGUID -Clear mS-DS-ConsistencyGuid
        $ret_code_4 = $?
        }

    [String]$ADUser[$i].SamAccountName + "," + [String]$ret_code_1 + "," + [String]$ret_code_2 + "," + [String]$ret_code_3+ "," + [String]$ret_code_4 >> $log

}

Get-Date >> $log

"$script ------------- 処理終了 -------------" >> $log

# 処理最後に、一覧取得
# --Ver1.1 Mod タブ区切りで出力--
$ADUser = Get-ADUser -SearchBase $SearchBase -Filter * -Properties ExtensionAttribute1,mS-DS-ConsistencyGuid 

# --Ver1.1 Mod タブ区切りで出力 Ver1.2 出力ファイル名修正--
$ADUser | Export-Csv -delimiter "`t" -Encoding Default -Path $new_list
  