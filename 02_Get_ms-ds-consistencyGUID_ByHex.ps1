
#######################################
#
# �쐬���F2022/04/01 Ver1.0
# �X�V���F2022/04/14 Ver2.0
#         "ExtensionAttribute1"�̒l���o�͂���悤�ǉ��B"mS-DS-ConsistencyGuid"�̒l�̏o�͂�S�̓I�ɏC��
#         2022/04/14 Ver2.1
#         DistinguishedName,ObjectGUID,SamAccountName�ǉ�
#         2022/04/14 Ver2.2
#         �^�u��؂�ŏo��(DistinguishedName �� ��� ��؂��Excel�ł̉��H���ނ�����)
#         2022/04/14 Ver2.3
#         ���ʃt�@�C���́Alog�͈ȉ��ɏo�͂���悤�ύX
#         2022/04/18 Ver2.4
#         �o�̓t�@�C�����̕ύX
#         2022/04/21 Ver2.5
#         msDS-cloudExtensionAttribute 1 2 ���o�͂���悤�ύX
# �@�\    �F"MsolUser.csv"�t�@�C����ǂݍ��݁AUPN��ImmutableID��Base64��16�i���\�L�ɕϊ������l���o�͂���
# ���s�ꏊ�F�I���v��AD��ɂĎ��s
#
#######################################

$formatdate = (Get-Date).ToString("yyyyMMddHHmmss")

# �X�N���v�g�� -- 2022/04/18 Add--
$script = $myInvocation.MyCommand.name

# --Ver2.4�ύX--
$out = "C:\temp\log\" + $script + "_ " + $formatdate + ".csv"

# ���ږ����o��
"DistinguishedName`tObjectGUID`tSamAccountName`tSID`tUserPrincipalName`tmS-DS-ConsistencyGuid`tmsDS-cloudExtensionAttribute1`tmsDS-cloudExtensionAttribute2" > $out

# ��������OU���w��
$SearchBase = "OU=People,DC=tokai,DC=tokaicarbon,DC=co,DC=jp"

# AD���[�U��  UserPrincipalName, mS-DS-ConsistencyGuid,  ExtensionAttribute1 ���擾
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

    
    # UserPrincipalName �� <���ݒ�>�Ȃ� "NULL" �Əo��
    if(  $UserPrincipalName -eq $null ){
       $UserPrincipalName = ""
    }
    

    # msDS-cloudExtensionAttribute1 �� <���ݒ�>�Ȃ� "NULL" �Əo��
    if(  $msDS_cloudExtensionAttribute1 -eq $null ){
       $msDS_cloudExtensionAttribute1 = ""
    }

    # msDS-cloudExtensionAttribute2 �� <���ݒ�>�Ȃ� "NULL" �Əo��
    if(  $msDS_cloudExtensionAttribute2 -eq $null ){
       $msDS_cloudExtensionAttribute2 = ""
    }

    # "mS_DS_ConsistencyGuid" �� <���ݒ�> �̏ꍇ
    if( $mS_DS_ConsistencyGuid -eq $null ){
        $mS_DS_ConsistencyGuid = ""

        # ----Ver2.1 Mod----
        # ----Ver2.2 Mod----
        $DistinguishedName + "`t" + $ObjectGUID + "`t"+ $SamAccountName + "`t" + $SID  + "`t" + $UserPrincipalName + "`t" + $mS_DS_ConsistencyGuid + "`t" + $msDS_cloudExtensionAttribute1 + "`t" + $msDS_cloudExtensionAttribute2 >> $out

     # "mS_DS_ConsistencyGuid" �ɒl�������Ă���ꍇ
     }else{

         $ubound = $mS_DS_ConsistencyGuid.count

         $HexString = ""

         for( $j=0; $j -lt $ubound; $j++){
             
             # 10�i���\�L��16�i���\�L�֕ϊ�
             $HexDecimal = [Convert]::ToString($mS_DS_ConsistencyGuid[$j],16)

             # "0"�̂Ƃ��́A0����
             $HexString = $HexString + " " + $HexDecimal.PadLeft(2,"0")

             # �p����啶���ϊ�
             $HexString = $HexString.ToUpper()

     
          }

          # ----Ver2.1 Mod----
          # ----Ver2.2 Mod----
          $DistinguishedName + "`t" + $ObjectGUID + "`t"+ $SamAccountName + "`t" + $SID  + "`t" + $UserPrincipalName + "`t" + $HexString + "`t" + $msDS_cloudExtensionAttribute1 + "`t" + $msDS_cloudExtensionAttribute2 >> $out
     }



    # ------------------

   



}
