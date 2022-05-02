#Connect-MSOlService
#Connect-AzureAD
#######################################
#
# 作成日：2022/04/01 Ver1.1
#         2022/04/18 Ver1.2
#         2022/04/18 Ver1.3 出力をタブ区切りに変更
#         2022/04/19 Ver1.4 extensitonAttribute1/extensionAttribute2 を出力するよう追加
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

$ret = $log_fol + $script + "_$formatdate.log"
#---------------





$MsolUser = Get-MsolUser
$MsolUser_count = $MsolUser.Count

# 列名出力
"UserPrincipalName" + "`t" + "ImmutableID" + "`t" + "LastDirSyncTime"+ "`t" + "objectID"+ "`t" + "msDS_cloudExtensionAttribute1"+ "`t" + "msDS_cloudExtensionAttribute2" + "`t" + "ProxyAddress" > $ret




 for ( $i = 0; $i -lt  $MsolUser_count; $i++ ){

[String]$UserPrincipalName = [String]$MsolUser[$i].UserPrincipalName

     $ex_attri_1 = ""
     $ex_attri_2 = ""
     $ProxyAddress = ""

     # 同期していないものは出力しない
     if( ([String]$MsolUser[$i].LastDirSyncTime) -eq "" ){ continue }


     # 文字列判定の仕方、ナニコレ
     if ( -Not ( ([String]$UserPrincipalName).Contains("#EXT#") -or ([String]$UserPrincipalName).Substring(0,5) -eq "Sync_" )){    
        
        # 属性値は KeyValue にて取得 --Ver1.4 Add-- 
        $HashTable = Get-AzureADUserExtension -ObjectId $MsolUser[$i].objectID

        # KeyCollection としてのキーを取得
        $KeyCollectionKeys = $HashTable.Keys

        # 配列に格納
        $KeyCollectionKey = @()
            foreach ( $KeyCollectionKey in $KeyCollectionKeys ){
                  #$Keys += $KeyCollectionKey

                  if ( ([String]$KeyCollectionKey).Contains("msDS_cloudExtensionAttribute1") ){ [String]$ex_attri_1 = ([String]$HashTable.$KeyCollectionKey) }
                  if ( ([String]$KeyCollectionKey).contains("msDS_cloudExtensionAttribute2") ){ [String]$ex_attri_2 = ([String]$HashTable.$KeyCollectionKey) }
            }


        $ProxyAddress = $MsolUser[$i].ProxyAddresses

        $UserPrincipalName + "`t" + $MsolUser[$i].ImmutableID + "`t" + $MsolUser[$i].LastDirSyncTime + "`t" + $MsolUser[$i].objectID + "`t" + $ex_attri_1 + "`t" + $ex_attri_2 + "`t" + $ProxyAddress >> $ret
    }


        
     
}
 
