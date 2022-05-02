#Connect-MSOlService
#Connect-AzureAD
#######################################
#
# �쐬���F2022/04/01 Ver1.1
#         2022/04/18 Ver1.2
#         2022/04/18 Ver1.3 �o�͂��^�u��؂�ɕύX
#         2022/04/19 Ver1.4 extensitonAttribute1/extensionAttribute2 ���o�͂���悤�ǉ�
# �@�\�FAzure AD��̃��[�U��UPN�EImmutableID�ELastDirSyncTime���o��
#       �� "#EXT#"�ƁAAADC���쐬����"Sync_" ����n�߂郆�[�U�͎擾���Ȃ�
# �C���F2022/04/11 LastDirSyncTime���o�͂���悤�ɏC��
#
#######################################

#     �� ���O�t�@�C�����o�͐� ��  --Ver1.2 Add--

          $log_fol = "C:\temp\log\"

$formatdate = (Get-Date).ToString("yyyyMMddHHmmss")

# �X�N���v�g��
$script = $myInvocation.MyCommand.name

$ret = $log_fol + $script + "_$formatdate.log"
#---------------





$MsolUser = Get-MsolUser
$MsolUser_count = $MsolUser.Count

# �񖼏o��
"UserPrincipalName" + "`t" + "ImmutableID" + "`t" + "LastDirSyncTime"+ "`t" + "objectID"+ "`t" + "msDS_cloudExtensionAttribute1"+ "`t" + "msDS_cloudExtensionAttribute2" + "`t" + "ProxyAddress" > $ret




 for ( $i = 0; $i -lt  $MsolUser_count; $i++ ){

[String]$UserPrincipalName = [String]$MsolUser[$i].UserPrincipalName

     $ex_attri_1 = ""
     $ex_attri_2 = ""
     $ProxyAddress = ""

     # �������Ă��Ȃ����̂͏o�͂��Ȃ�
     if( ([String]$MsolUser[$i].LastDirSyncTime) -eq "" ){ continue }


     # �����񔻒�̎d���A�i�j�R��
     if ( -Not ( ([String]$UserPrincipalName).Contains("#EXT#") -or ([String]$UserPrincipalName).Substring(0,5) -eq "Sync_" )){    
        
        # �����l�� KeyValue �ɂĎ擾 --Ver1.4 Add-- 
        $HashTable = Get-AzureADUserExtension -ObjectId $MsolUser[$i].objectID

        # KeyCollection �Ƃ��ẴL�[���擾
        $KeyCollectionKeys = $HashTable.Keys

        # �z��Ɋi�[
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
 
