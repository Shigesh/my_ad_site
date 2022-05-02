####################################################

# 作成日      ：2022/04/01 Ver1.0
# 更新日      ：2022/04/01 Ver1.1
# スクリプト名： 03_Set_ms-ds-consistencyGUID_ByHex.ps1
# ログ 出力先 ： C:\temp\log
# 機能        ： "mS-DS-ConsistencyGuid"（16進数）をCSVファイルから読み込み、指定されたOU配下のユーザにセットする
# 引数        ： なし
# 戻り値      ： なし
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

# CSV 読み込み
$a = Import-Csv -delimiter "`t" -Encoding UTF8 -path $in

# CSVファイルの行を列名を除いてカウント
$lines = $a.Count
#$lines

# 指定したOU 配下のユーザの属性値を "mS-DS-ConsistencyGuid" を含めて取得
$ADUser_array = Get-ADUser –Filter * -Properties mS-DS-ConsistencyGuid -SearchBase $SearchBase

# 指定したOU 配下のユーザのカウント
$ADUser_count = $ADUser_array.Count

# 列名出力
"No,DistinguishedName,UserPrincipalName,result" >> $log 

for ($i = 0; $i -lt $lines; $i++){

     # 行番号
     [Int]$No = $i + 1 

     # CSVファイルの "mS-DS-ConsistencyGuid" の値を取得

     $csv_mS_DS_ConsistencyGuid = $a[$i].'mS-DS-ConsistencyGuid'
     $csv_upn =$a[$i].'new_UserPrincipalName'  #--Ver1.1 追加--

     #$csv_mS_DS_ConsistencyGuid
     #$csv_upn

     if ($csv_mS_DS_ConsistencyGuid -eq ""){

         $ret_code = -9
         "$No,$csv_upn,-,$ret_code" >> $log
         continue

     }else{

         # ---(処理内容)：16進数のオクテット文字列 → 空白除去 → ２文字("02"とか)を16進数の数値に変換 → 16進数の数値からGUIDを取得---
         $hexstring = $csv_mS_DS_ConsistencyGuid
         $guid = [GUID]([byte[]] (-split (($hexstring -replace " ", "") -replace '..', '0x$& ')))
     
             for( $j = 0; $j -lt $ADUser_count; $j++){

                  # AD上 と CSVファイルのUPNを比較し、一致し
                  if( $ADUser_array[$j].'UserPrincipalName' -eq $csv_upn ) {

                  #$ADUser_array[$j].'UserPrincipalName'
                  #$csv_upn

                      # かつ 'mS-DS-ConsistencyGuid' の値が空白の場合
                      if([string]::IsNullOrEmpty($ADUser_array[$j].'mS-DS-ConsistencyGuid')){


                           # ------------"'ms-DS-ConsistencyGUID" をADユーザにセット -------------------
                           Set-ADObject -Identity $ADUser_array[$j].'DistinguishedName' -Replace @{'ms-DS-ConsistencyGUID'=$guid}
                           $ret_code = $?

                           
                           # 行番号、DistinguishedName、UserPrincipalName、処理結果をログに出力
                           [String]$No + "," + $ADUser_array[$j].'DistinguishedName' + "," + $ADUser_array[$j].'UserPrincipalName' + "," + $ret_code >> $log
                           break
                       }else{

                           # mS-DS-ConsistencyGuid の値に値が入っていた場合、$ret_code を-1 にセット
                           $ret_code = "-1"
                           [String]$No +  "," + $ADUser_array[$j].DistinguishedName + "," + $ADUser_array[$j].UserPrincipalName + "," + [String]$ret_code>> $log
 
                       }
                  }
             }
     }

}

Get-Date >> $log

"$script ------------- 処理終了 -------------" >> $log

