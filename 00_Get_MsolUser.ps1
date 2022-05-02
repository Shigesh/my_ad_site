#Connect-MSOlService
#######################################
#
# 作成日：2022/04/01 Ver1.1
#         2022/04/18 Ver1.2
#         2022/04/18 Ver1.8 出力をタブ区切りに変更
#         2022/04/18 Ver1.9 文字列判定ができていないバグ修正
# 機能：Azure AD上のユーザのUPN・ImmutableID・LastDirSyncTimeを出力
#       ※ "#EXT#"と、AADCが作成する"Sync_" から始めるユーザは取得しない
# 修正：2022/04/11 LastDirSyncTimeを出力するように修正
#
#######################################

#     ◆ ログファイル名出力先 ◆  --Ver1.2 Add--

          $log_fol = "C:\temp\log\"

$formatdate = (Get-Date).ToString("yyyyMMddHHmmss")

# スクリプト名
$script = $myInvocation.MyCommand.name

$log = $log_fol + $script + "_$formatdate.log"
#---------------



$ret = "$log"

$MsolUser = Get-MsolUser
$MsolUser_count = $MsolUser.Count

# 列名出力
"UserPrincipalName" + "`t" + "ImmutableID" + "`t" + "LastDirSyncTime"+ "`t" + "objectID" > $ret

 for ( $i = 0; $i -lt  $MsolUser_count; $i++ ){

$UserPrincipalName = $MsolUser[$i].UserPrincipalName

     if( -Not (([String]$UserPrincipalName).Contains("#EXT#") -or ([String]$UserPrincipalName).Substring(0,5) -eq "Sync_")){ 
     
        $UserPrincipalName + "`t" + $MsolUser[$i].ImmutableID + "`t" + $MsolUser[$i].LastDirSyncTime + "`t" + $MsolUser[$i].objectID >> $ret
     
     }
 }
