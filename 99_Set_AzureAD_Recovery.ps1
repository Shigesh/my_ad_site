#Connect-MSOlService
#######################################
#
# �쐬���F2022/04/18 Ver1.0
#         
# �@�\�F00_Get_MsolUser.ps1 �̎��s���� �u00_Get_MsolUser.ps1.log�v�t�@�C����ǂݍ���
#       objectID ���L�[�� UserPrincipalName ���Z�b�g����
#       �� "#EXT#"�ƁAAADC���쐬����"Sync_" ����n�߂郆�[�U�͎擾���Ȃ�
# �C���F2022/04/11 LastDirSyncTime���o�͂���悤�ɏC��
#
#######################################

# �X�N���v�g��
$script = $myInvocation.MyCommand.name

# ���O�t�H���_
$log_fol = "C:\temp\log\"
$formatdate = (Get-Date).ToString("yyyyMMddHHmmss")

# ���O�t�@�C��
$log = $log_fol + $script + "_$formatdate.log"
"old_UserPrincipaleName" + "`t" + "new_UserPrincipaleName"  + "`t" + "ret_code" >> $log

# CSV�t�@�C���̓ǂݍ���(�^�u��؂�)
$Get_MsolUser_csv = Import-Csv -Path "C:\temp\input\input_r.csv" -Delimiter "`t"
$ubound = $Get_MsolUser_csv.Count


 for ( $i = 0; $i -lt  $ubound; $i++ ){

         $old_UserPrincipaleName = (Get-MsolUser -ObjectId $Get_MsolUser_csv[$i].objectID).UserPrincipalName

         Set-MsolUserPrincipalName -ObjectId $Get_MsolUser_csv[$i].objectID -NewUserPrincipalName $Get_MsolUser_csv[$i].new_UserPrincipalName
         $ret_code = $?

         $new_UserPrincipaleName = (Get-MsolUser -ObjectId $Get_MsolUser_csv[$i].objectID).UserPrincipalName

         $old_UserPrincipaleName + "`t" + $new_UserPrincipaleName  + "`t" + $ret_code >> $log
     

     
}

