
#######################################
#
# �쐬���F2022/04/01  Ver1.0
# �@�\�F"MsolUser.csv"�t�@�C����ǂݍ��݁AUPN��ImmutableID��Base64��16�i���\�L�ɕϊ������l���o�͂���A
#
#######################################

$formatdate = (Get-Date).ToString("yyyyMMddHHmmss")

# ���̓t�@�C����  --Ver1.1 Add--
$in = "C:\temp\00_Get_MsolUser.ps1.log"

# �X�N���v�g��  --Ver1.1 Add--
$script = $myInvocation.MyCommand.name


# �o�̓t�@�C����  --Ver1.1 Mod--
$out = "C:\temp\" + $script + "_$formatdate.log"

# �񖼏o��
"UPN" + "`t" + "mS-DS-ConsistencyGuid" > $out

$f = (Import-CSV -delimiter "`t" -Path $in)

$lines = $f.count

for ($i = 0; $i -lt $lines; $i++){

    $Immu = $f[$i].ImmutableID
       
    # Base64���G���R�[�h���A16�i���\�L�ɕϊ�
    $mSDSConsistencyGuid = [System.Convert]::FromBase64String($Immu) | Format-Hex -Encoding Ascii
    
    $ImmutalbleID_Hex_Col = $mSDSConsistencyGuid -split(" ")
    
    $ImmutalbleID_Hex = $ImmutalbleID_Hex_Col[3..18] -join " "

    # UPN��mS-DS-ConsistencyGuid���o��
    $f[$i].UserPrincipalName + "`t" + $ImmutalbleID_Hex >> $out

}
