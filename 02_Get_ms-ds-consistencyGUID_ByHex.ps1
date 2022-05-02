
#######################################
#
# 作成日：2022/04/01 Ver1.0
# 更新日：2022/04/14 Ver2.0
#         "ExtensionAttribute1"の値を出力するよう追加。"mS-DS-ConsistencyGuid"の値の出力を全体的に修正
#         2022/04/14 Ver2.1
#         DistinguishedName,ObjectGUID,SamAccountName追加
#         2022/04/14 Ver2.2
#         タブ区切りで出力(DistinguishedName が ｶﾝﾏ 区切りでExcelでの加工がむつかしい)
#         2022/04/14 Ver2.3
#         結果ファイルは、logは以下に出力するよう変更
#         2022/04/18 Ver2.4
#         出力ファイル名の変更
#         2022/04/21 Ver2.5
#         msDS-cloudExtensionAttribute 1 2 を出力するよう変更
# 機能    ："MsolUser.csv"ファイルを読み込み、UPNとImmutableIDをBase64を16進数表記に変換した値を出力する
# 実行場所：オンプレAD上にて実行
#
#######################################

$formatdate = (Get-Date).ToString("yyyyMMddHHmmss")

# スクリプト名 -- 2022/04/18 Add--
$script = $myInvocation.MyCommand.name

# --Ver2.4変更--
$out = "C:\temp\log\" + $script + "_ " + $formatdate + ".csv"

# 項目名を出力
"DistinguishedName`tObjectGUID`tSamAccountName`tSID`tUserPrincipalName`tmS-DS-ConsistencyGuid`tmsDS-cloudExtensionAttribute1`tmsDS-cloudExtensionAttribute2" > $out

# 検索するOUを指定
$SearchBase = "OU=People,DC=tokai,DC=tokaicarbon,DC=co,DC=jp"

# ADユーザの  UserPrincipalName, mS-DS-ConsistencyGuid,  ExtensionAttribute1 を取得
# ----Ver2.0 Add ExtensionAttribute1----
$a = Get-ADUser -Properties UserPrincipalName, mS-DS-ConsistencyGuid, msDS-cloudExtensionAttribute1, msDS-cloudExtensionAttribute2 -Filter * `
                -SearchBase $SearchBase



$all_user = $a.count

for($i = 0; $i -lt $all_user; $i++){


    $DistinguishedName = ""
    $ObjectGUID = ""
    $SamAccountName = ""
    $SID = ""
    $UserPrincipalName = ""
    $msDS_cloudExtensionAttribute1 = ""


    # ----Ver2.1 Mod----
    $DistinguishedName = $a[$i].DistinguishedName
    $ObjectGUID = $a[$i].ObjectGUID
    $SamAccountName =$a[$i].SamAccountName
    $SID = $a[$i].SID

    # ----Ver2.0 Mod----
    $UserPrincipalName = $a[$i].UserPrincipalName
    $msDS_cloudExtensionAttribute1 = $a[$i].'msDS-cloudExtensionAttribute1'
    $msDS_cloudExtensionAttribute2 = $a[$i].'msDS-cloudExtensionAttribute2'
    $mS_DS_ConsistencyGuid = $a[$i]."mS-DS-ConsistencyGuid"

    
    # UserPrincipalName が <未設定>なら "NULL" と出力
    if(  $UserPrincipalName -eq $null ){
       $UserPrincipalName = ""
    }
    

    # msDS-cloudExtensionAttribute1 が <未設定>なら "NULL" と出力
    if(  $msDS_cloudExtensionAttribute1 -eq $null ){
       $msDS_cloudExtensionAttribute1 = ""
    }

    # msDS-cloudExtensionAttribute2 が <未設定>なら "NULL" と出力
    if(  $msDS_cloudExtensionAttribute2 -eq $null ){
       $msDS_cloudExtensionAttribute2 = ""
    }

    # "mS_DS_ConsistencyGuid" が <未設定> の場合
    if( $mS_DS_ConsistencyGuid -eq $null ){
        $mS_DS_ConsistencyGuid = ""

        # ----Ver2.1 Mod----
        # ----Ver2.2 Mod----
        $DistinguishedName + "`t" + $ObjectGUID + "`t"+ $SamAccountName + "`t" + $SID  + "`t" + $UserPrincipalName + "`t" + $mS_DS_ConsistencyGuid + "`t" + $msDS_cloudExtensionAttribute1 + "`t" + $msDS_cloudExtensionAttribute2 >> $out

     # "mS_DS_ConsistencyGuid" に値が入っている場合
     }else{

         $ubound = $mS_DS_ConsistencyGuid.count

         $HexString = ""

         for( $j=0; $j -lt $ubound; $j++){
             
             # 10進数表記を16進数表記へ変換
             $HexDecimal = [Convert]::ToString($mS_DS_ConsistencyGuid[$j],16)

             # "0"のときは、0埋め
             $HexString = $HexString + " " + $HexDecimal.PadLeft(2,"0")

             # 英字を大文字変換
             $HexString = $HexString.ToUpper()

     
          }

          # ----Ver2.1 Mod----
          # ----Ver2.2 Mod----
          $DistinguishedName + "`t" + $ObjectGUID + "`t"+ $SamAccountName + "`t" + $SID  + "`t" + $UserPrincipalName + "`t" + $HexString + "`t" + $msDS_cloudExtensionAttribute1 + "`t" + $msDS_cloudExtensionAttribute2 >> $out
     }



    # ------------------

   



}
