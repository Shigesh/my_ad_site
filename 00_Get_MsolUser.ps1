#Connect-MSOlService
#######################################
#
# �쐬���F2022/04/01 Ver1.1
#         2022/04/18 Ver1.2
#         2022/04/18 Ver1.8 �o�͂��^�u��؂�ɕύX
#         2022/04/18 Ver1.9 �����񔻒肪�ł��Ă��Ȃ��o�O�C��
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

$log = $log_fol + $script + "_$formatdate.log"
#---------------



$ret = "$log"

$MsolUser = Get-MsolUser
$MsolUser_count = $MsolUser.Count

# �񖼏o��
"UserPrincipalName" + "`t" + "ImmutableID" + "`t" + "LastDirSyncTime"+ "`t" + "objectID" > $ret

 for ( $i = 0; $i -lt  $MsolUser_count; $i++ ){

$UserPrincipalName = $MsolUser[$i].UserPrincipalName

     if( -Not (([String]$UserPrincipalName).Contains("#EXT#") -or ([String]$UserPrincipalName).Substring(0,5) -eq "Sync_")){ 
     
        $UserPrincipalName + "`t" + $MsolUser[$i].ImmutableID + "`t" + $MsolUser[$i].LastDirSyncTime + "`t" + $MsolUser[$i].objectID >> $ret
     
     }
 }
