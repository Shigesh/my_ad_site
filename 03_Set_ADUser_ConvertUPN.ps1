####################################################

# 作成日                ：2022/04/06 Ver1.0
# 更新日                ：2022/04/14 Ver1.1
#                         SIDをキーに処理していたが、 ObjectGUIDに変更(お客様からはこれで来ると思われるため) 
#                         2022/04/14 Ver1.2
#                         出力ファイル名の修正
#                         2022/04/15 Ver1.3
#                         入力ファイル名の修正
#                         2022/04/18 Ver1.4
#                         ObjectGUID の値の取得を変更
# スクリプト名          ： 04_Set_ADUser_ConvertUPN.ps1
#
# 入力 ファイル名       ： C:\temp\input\input.csv
#                          "Get-ADUser -SearchBase $SearchBase -Filter *" で取得したファイルに 
#                          "new_UserPrincipalName" の列を追加し、追加した列に新しいUPNが記載されていること
#
# ログ 出力先           ： C:\temp\log
# ログ ファイル名       ： 04_Set_ADUser_ConvertUPN.ps1_yyyyMMddHHmmss.log（処理結果ログ）
#                       ： 04_Set_ADUser_ConvertUPN.ps1_yyyyMMddHHmmss_list_old.csv（処理前の一覧）
#                       ： 04_Set_ADUser_ConvertUPN.ps1_yyyyMMddHHmmss_list_new.csv（処理後の一覧）
# 
# 機能                  ： 「入力ファイル」に出力された SID をキーにUPNの変更する
#
# 引数                  ： なし
# 戻り値                ： なし
# 定数                  ：
#
#     ◆ 対象となるOU ◆

          $SearchBase = "OU=People,DC=tokai,DC=tokaicarbon,DC=co,DC=jp"

#     ◆ ログファイル名出力先 ◆

          $log_fol = "C:\temp\log\"

#     ◆ インプットファイル名 ◆--2022/04/18 ADD--

          $input_file = "C:\temp\input\input.csv"
#         ※04_input.csv  列名：sAMAccountName,old_userPrincipalName,new_userPrincipalName  


####################################################

$formatdate = (Get-Date).ToString("yyyyMMddHHmmss")

# スクリプト名
$script = $myInvocation.MyCommand.name

# ログ
$log = $log_fol + $script + "_$formatdate.log"
"No,Name,old_userPrincipalName,new_userPrincipalName,result" > $log

# 作業前の一覧
$old_list = $log_fol + $script + "_$formatdate" + "_list_old.csv"

# 作業後の一覧
$new_list = $log_fol + $script + "_$formatdate" + "_list_new.csv"

# 作業前の一覧
$ADUser = Get-ADUser -SearchBase $SearchBase -Filter * 

# --Ver1.1 Mod タブ区切りで出力--
$ADUser | Export-Csv -delimiter "`t" -Encoding Default -Path $old_list

# 配下のユーザカウント
$ADUser_cnt = $ADUser.count


# 設定ファイル読み込み --2022/04/18 ADD--
$input_csv = Import-Csv -delimiter "`t" -Path $input_file
$input_csv_cnt = ($input_csv | measure).count  # measureを入れないと１行しかないときNG。PSの仕様
#$input_csv[3]


[Int]$No = 0

# -------------Main-----------------
for($i = 0; $i -lt $ADUser_cnt; $i++){


    for($j = 0; $j -lt $input_csv_cnt; $j++ ){


        # SIDが一致したら UserPrincipalName を変更する
        
        #if($ADUser[$i].SID.value -eq $input_csv[$j].SID){
       
       #$ADUser[$i].ObjectGUID.Guid >> C:\temp\hogehoge_0.txt
       #$input_csv[$j].ObjectGUID >> C:\temp\hogehoge_1.txt

       $old_UserPrincipalName = ""

        # --Ver1.1 Mod-- Ver1.3 Mod--
        if( ( $ADUser[$i].ObjectGUID ).Guid -eq $input_csv[$j].ObjectGUID){


           [Int]$No += 1

           # ログ出力用に書き換え前の UserPrincipalName の値を保持
           $old_UserPrincipalName = $ADUser[$i].UserPrincipalName

           # CSVファイルを読み込み、"new_UserPrincipalName" の値を UserPrincipalName にセット
           Set-ADUser -Identity $ADUser[$i] -UserPrincipalName $input_csv[$j].new_UserPrincipalName

           # 同じ値に書き換えた場合も $ret_code は "True"
           $ret_code = $? 

           # ログファイル出力  名前,書き換え前の UserPrincipalName 書き換え後の UserPrincipalName ,Set-ADUser コマンドの戻り値(TrueならOK)
           [String]$No + "," + $ADUser[$i].Name + "," + $old_UserPrincipalName + "," + $input_csv[$j].new_UserPrincipalName + "," + $ret_code >>  $log

           break
        
        }
    }
    
}

# ---------------------------------

# 処理最後に、一覧取得
# --Ver1.1 Mod タブ区切りで出力--
$ADUser = Get-ADUser -SearchBase $SearchBase -Filter * 

# --Ver1.1 Mod タブ区切りで出力 Ver1.2 出力ファイル名修正--
$ADUser | Export-Csv -delimiter "`t" -Encoding Default -Path $new_list
  