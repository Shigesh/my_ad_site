#Connect-MSOlService
#######################################
#
# 作成日：2022/04/18 Ver1.0
#         
# 機能：00_Get_MsolUser.ps1 の実行結果 「00_Get_MsolUser.ps1.log」ファイルを読み込み
#       objectID をキーに UserPrincipalName をセットする
#       ※ "#EXT#"と、AADCが作成する"Sync_" から始めるユーザは取得しない
# 修正：2022/04/11 LastDirSyncTimeを出力するように修正
#
#######################################

# スクリプト名
$script = $myInvocation.MyCommand.name

# ログフォルダ
$log_fol = "C:\temp\log\"
$formatdate = (Get-Date).ToString("yyyyMMddHHmmss")

# ログファイル
$log = $log_fol + $script + "_$formatdate.log"
"old_UserPrincipaleName" + "`t" + "new_UserPrincipaleName"  + "`t" + "ret_code" >> $log

# CSVファイルの読み込み(タブ区切り)
$Get_MsolUser_csv = Import-Csv -Path "C:\temp\input\input_r.csv" -Delimiter "`t"
$ubound = $Get_MsolUser_csv.Count


 for ( $i = 0; $i -lt  $ubound; $i++ ){

         $old_UserPrincipaleName = (Get-MsolUser -ObjectId $Get_MsolUser_csv[$i].objectID).UserPrincipalName

         Set-MsolUserPrincipalName -ObjectId $Get_MsolUser_csv[$i].objectID -NewUserPrincipalName $Get_MsolUser_csv[$i].new_UserPrincipalName
         $ret_code = $?

         $new_UserPrincipaleName = (Get-MsolUser -ObjectId $Get_MsolUser_csv[$i].objectID).UserPrincipalName

         $old_UserPrincipaleName + "`t" + $new_UserPrincipaleName  + "`t" + $ret_code >> $log
     

     
}

