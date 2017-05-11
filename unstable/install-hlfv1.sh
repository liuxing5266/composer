(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -ev

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# Pull the latest Docker images from Docker Hub.
docker-compose pull
docker pull hyperledger/fabric-ccenv:x86_64-1.0.0-alpha

# Kill and remove any running Docker containers.
docker-compose -p composer kill
docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
docker ps -aq | xargs docker rm -f

# Start all Docker containers.
docker-compose -p composer up -d

# Wait for the Docker containers to start and initialize.
sleep 10

# Create the channel on peer0.
docker exec peer0 peer channel create -o orderer0:7050 -c mychannel -f /etc/hyperledger/configtx/mychannel.tx

# Join peer0 to the channel.
docker exec peer0 peer channel join -b mychannel.block

# Fetch the channel block on peer1.
docker exec peer1 peer channel fetch -o orderer0:7050 -c mychannel

# Join peer1 to the channel.
docker exec peer1 peer channel join -b mychannel.block

# Open the playground in a web browser.
if [ "$(uname)" = "Darwin" ]
then
  open http://localhost:8080
fi

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �hY �]Ys�Jγ~5/����o�Jմ6 ����)�v6!!~��/ql[7��/�ݍ���s�s:��n�O��/�i� h�<^Q�D^���Q�D(�¨/�c��F~Nwc����V��N��4{��k��P����~�MC{9=��i��>dF\.�&�J�e�5�ߖ��2.�?�8Uɿ�Y���4��%I���P�wo{�{�l�\�Z�9�%���}��S���p��)�+���k��O'^���r�I�8
�"�;y?��{4%�B�;�ԟG���럵{������]��]�<�l�%l��i��X�$l�sY��|�t|ԧ)��\��(�EQ�'����^�������"^��8�>��x�Y�K)c �p�u'6d�&�B�z�lC��E�T)M��(�2�I}a,0���F)�[e�ւ6U�	�e���i�ϯ}�`!���x�	Z��Աc���#��sݧ(��h��:���OYz8�l%�n���Ri&������Ł��"�-T?�%�^|��}��:+��K_��������M�������èj��|���*��o�?z��W�?J��S�O���/�?/�,�|a6o-�,�M���A.s �5e)�ɬ�m�!ǳ�Rܶ���\�&�Y��i�q��e9�k�`jZC�[�� J� �D�S�&e�p�u#2�q�pک��)� �6�8�C֐��#u�D]���Ev����A܉�q�jr@1�&��Z=7rw
G� �qEPr�x=X�b�#���2y���rK;
��{0Qx�Tv����Ρ��Չ�XD���Cq'���\��Y�M��I[,���ā�q�t1�Ӹb>��Cso୥bpc�S��L� O
��
p�����yxsh���H"S�n$L�^�[\c�ƨ��s��/;hS@�N��䒡ʅ�ʻ�R�L�ŭ�L�f�E�F�S q������k�Q���Nc��#/�����V�xn,)@�@�����u���(��EƤ����7+&@fK��(�t isy�1����R��(y��@����u��@.|[$�%���1�e�����}v�7��k�r�-'iKj����Ŭ��,��Ez ǢϙE/�f�\�}X|�6<���f��_���4|����Q���R�A�T��x��ѧ�������k�/�
�w�;�ׁzd�7�;u��%�-��=q��%��|�!G�8*�#F��P�1��	���#;� � WS�.�
�{e�ޗ)����u~�e��i(��C�م��<��.G�މE�r	��b�֐�ek�Dj�b���:w��-��uy�H�\̭���!�� 
@s�e��p�i�=�mu�4@.�'���	s�p��ax�@����4���Y�@��
�9�W ����&3��r9!��Y��g���n���P��{��oi&�MI!%i㧓F�s��@[�!jCꃙm3�i|����$�E�|����Ś����`�~�n3�'0 ������\ג�p5E�̪9�8L�!����S���w�7��{��$�*��|���yO���Q����*����?���������@q���2�K�������+U�O�����O��$�^@�lqu�"���4e�"���N��~�d�b4�z�W���](C���?���H������?|�'��&�<i�'�ˬ�YB�+"�8�0��(�������ll��m3b2n�I���-�/�eK֓�9�6��s�i��nG�sln���_n�ۭ �Q���R��a���^���f�O��_
>J����T��T���_��W�����f�O���������C�����-�gz����C��!|��l����:�f��w�б[��{�Ǯ��|h ���A����p\�� ��I��!&��{SinM�	����0w�s��t��$��P�s��m6�7�y�ֻ� 
�4%
��<.t��ʝ��1vL���k̑��#�r68f$�{������[�i��J �J�0$�@ ��7PĖ �!/X��k�N8a7E�j�de:�� �n��;���GӞ=�4�*���TQ��w{�χf=�/��$d�����f�u��LiYZw4�C^nvL5QBډI�H�,E�vC2�	\��d�Ѓ������%����?h��e�C���?���*����*��s��7��~�`��?Z����\"�Wh�E\��Q�U�_*������?����?�z� hQ�T�e����t�"�GC�'��]����p����-x�a	�DX�qX$@H�Ei�$)�����P��/��Ch����2pA��ʄ]�_�V�byñ9�5�f{�9Ҫ�l�m��Rx1�%���q�N+)54$wm'���ǫ{���(ǌ��v��7pD���������=n2�L?�SJN�v�*���x��q���q���D��_� ���<��?Tu�w9�P���/3
��'�J�K�{���������r��8�T�/)����^,Őj�o)��0}���������?K#t������6�26�R��Q��,��x4B��x���o���BQi(C���������j���q��O���>H-�j7���X&��\=V�k��������Հ&\xٮ��sX]W|.E�T�;��ͣ�L8�u>ʼf$���-�?����!�V�g"�	���� ����֫��w�#�����������J�����$������������$�P}i�P�2Q��_��P�|��MP�e����1��㿟��9+9�V���% ��7�g�?�g}��$������7����*-û���֍��{�� �7�ݰ����s��]k?�ڹg�@������)�b^|��Զ�1���t�o�0��"F�E7Ӭ����	5��D�Xo�Ql�f:Gm᭸h.)�74L��(g=�@�p[�G1��#�Gz�I��9}��I,̹����p�wk�ʹ�Q�hMX���UjS����ҝJ���9�[a��5� �RgD��ކ��t�w��n7�5���`��Ԝ��]]q��B[��n;i�圳�xJX9[��1�C�y��L;AO�%�����ӻ�����E�/��4����>������?NT�)�-�
����	���?���e��U����O����K�������� ���5��͝dv�
9���D����Q�'�����(6��6��u���>�=a�èj
����$l��?9zp Dbl'�����>���$���ld�l�k��e+=5%���ʱkiBÐNe3&ɜ��ep*7<��k����q�W��k�A@O�x�ygw������f��9r5��Z�lޥ�ݴo���<k$���Ž������Z�-Xr�\���������i4l����BEا���<�)>���t���?BSU�_)�-��Y�G���$|��W����!�w��ӕ�_���j��Z�����h��u
���?�a��.���r��b��(���?KA���W�����o��CQ�����V
.��#l��0�D)ơH�p�g0�D|g4�iGp%2`}*�}�\sëS`~+�!�W����r��W����� �eJ���-sjư���S�m�m+[,�Fi�5yq��1��t�V�֕�FwGѽdMq=�o{;�cN��sh}�
��A~
ӻ�N���r���)�2�Q_��,6��y����bw�GI����h����������O�!P�:��l�4+����_�_���v���W�Vsm�x�զ��_k�}��ul'��W��u�P7q�^#�ȕ�H&��3�r;M�e�/���jW5	p������U�o��v�����?=}0��u������z��SY1q#{�}�e�ڕ[���=jG�kWE��q�"�.�ګO~r����������|��y�+�v�`���3���]y�!�ƋM�?�k��Sݾ��[܎�rmO�~z���bV����͠����p;s�6��}eZ�6�hnuuA�E��!��:7�o�*]���!ק?/�>^�r_�fW�v��kM%��|��^�q�����W�v��}��]t�~O�u�(޼�Z���=����a{�F�S����j/�����-�D��i�Ž{x��}Ԑ���AP�����O�w������[������{l��W[ ����ߩ�y�Χ��ƛ�_kp���0N���R���ƹ.L��������'������"?2g3�\��&�f����pF�=��é��pls�a໺x�7���]A�G"?0DCV�����=��mUqd|[��q��:#���j|�,���0O�lo�N7K��I]g��ɞ����.�q�:ۛ�z|�^�i$Y������b'k��~(�uLQ���(���Rcá(R%rH��0
8@� )
�5H�$ȃ�h�ڠ}h��%�C�@;�����>���$�4�f4���uyء�sy�w?����a�/�b�ٜu0����-����y�8�g�t�N�2d>��v�+��ҹ\"s+��%�$��u혁��NB���2�M�I{�ʹ�e �Z����ż&�y	xs[�sB	��0-�\]Yt�UEQ\���ZM��p	24A���a�Ԏ�ɀ�a� ���]f\�a�Xxd��ݮf@݄�h<9UIp�>:��G��;����x:�����|)�eXh92-A�U�|O�C�[�9���93�<ssZ�5Bs���آJ��y_����>�h��>O���j�4e�:j�&vj�-�۝���)�b���`��*yߢ�:@��S�,p�6����NKpJ�_�S�;��ى����n�j|�]���ɽ�]�i�~SS�����NmՀ?Ax�S�OX�F�5wY�='5v����4�I��8�Ƨ\O����}�r�aG;�`vFW�ga��Ԃ���IW���k����2?*QAohf�`��v�h+��g��|](8-��-_�HU䕜��)U�-�� }R�7��Mk��U��uT��|�� ��,	5:}�%.-�̞���O�vt���t�l��kD;�b>�W����s�.5�9��V����ǒ4�DĔ�N��o:�B�.3,h�ߖ�,{<m�u�'�B69��Ç��Z�b���l���ZU��ۅ��]��v��`�Յ�]����Og�V��l�4��^_!8<��b������ݪ���?^���g��n����y�x-	���;�����_������*q�}��z|�z�)ćxlߏ�� �%�����x�o?P�{��@j�Ob�O���'".p��ޑ��t�x�����Ň깯^x���?��[/��3�kx����|�A���t#�x�ø8��c;�t|�<|��א/_[���O 5�sS��tS���+-��7o0��y`B�#qYH�ya�66��̏x�s��&Y��'�y�Y�����o��Æ�dO ���V�J�F�}ԛHU�ro�[B��0G{�B�S���cN(u�v	c���"YaX��}Ќ�t�<.�D�Yl�g��m�`ɊI�Hvs��[���"����0*0�Va�h|@Ȇ8̲y6<�.1�*l�'g«d�1����R$�͏�Z���)K:�T��F3_0R�U)�j���zGJHi�ȣᴁJ)c���*��ň��=��i��Y�0dU+Ǒ���_r���a�nE�~"��GL�e�E��ܦ�a�M=�)�5?��f����Ss#dݫG��F<���1/��Nz��P.��w��~Uh&Uth$1P�Ź0^(Ҹ�vZ�5О��r.J�[�h1�� ��!+͍{\�V3(�A� ��r<��)t	Y�/�N�,!+ً������dCu���U�b�ˍr5���@���O6�$�r��j��P��B=�N���~*Y�Ԓ�q��		.v�6�ﾲD�IY�l���,{��n�?�%�ZI�Q�x��Z��c	+�^rB'-�{�x��:�Z�%ʙ��f¥$#{�Z'c
UmT�}�t�Br
[4�
c��L0,��"��(�%e9"� �VY⺏��C<Ӕ�l�ī��A����y_4�fe��e4�������{XXgұF+��jqP����DJ
u�"��VY��e�BY��+Kse�㉁�1�W�8M{�<�R�<���؛�zc�]�/~4�eE�C��ң�/�{�nj\���dK8��Q,���PS��)KTN7��(F�q=TUA��2�l�*pؒ�^�]�,\d���8���Ɛ�*����Q�����SR��Oy��n	p�nK�Tzh�u�K)ŀ����X>-��6Jy}�r���,n�gs|6�g��g۹D��>Í��Kz�+��ȵ�;�d��^غc�
r�������G��e�˳�\�ϳ}�|UY��������{�|W������" w���~O۰EW(]�^eT�!������ �Z�T��ɝ����$����ް^i��\U�Q���1zF~���6r	\4TE�E���5��XD>�\���?�-���ϻ�n�����\��f��/�27��a�X�F�j9�Q�>(|�};�ʳ�͖�������u� ߺ.���bR��ב#f`�
�#�Gv0(�dU7_���
 ��
�o��c���&���o#oo#��>,�y(p
6~(x�ĩ{��`�^x��Д����D)L���hϷ�_ZxP:��mu�d�VGs��h~2iX��Ê=��}e�邃�#�p�g���1߬9����I�=`� Rb*������̮��i���c�P�B�Xy�H��c����,��� D~)��e��W)�E�ܦ�l�*�fy����R���LkM2&�	�����5���ݘ͒֔=`f�C%��TC1=zT��O�����ivRc���k%zA�b�xpL(�jɠ6�w4\VI>��:�G��M#0.�v�Ñ1�{!q�R�#�{4��E�Z�["�>�W�y�E�y�a�ل�kn�8�p��?�s�%=�<�ʏ�9��Mh����L��l��	�Q(��\����v�C�w�ayO����o?=;Ʒ������xXN$�I�t��G�V%ZKc��i.�$���XR ��78r8Y,��h-*7Il!�"��8kPd�*0	��7kβ���ab���`1��m-E�� )G�2
����C�;��E���3r1^�0��U�O����x}=RU���h4��l%�`LB��K�����p�`�a,�*���(���!�|�-v����+`qO���b����K;� C���Ƥ S��J�F�E5\��c4ϥ0f��QN"lmO-���qCN�)$Z� |��E�ڬb�^?Mz�
-�����c�q�3�Sy?�ň�FN���N�B�B_��6���Ya����!7:R����nO���[���s��ӈ&Y��a����}d^[�:؞J*�
� ���rq���w@p�Qy|)�j6	ޏ����ͽ	lf��/|ﭽΏ�S���߼���~��Ͻ�_/����{��@xk��k������Ϲ�����������-	�w\���O��Y��ꛗ��;�<p��������|�+���_�_D��_K��K� xh�N﷾mqE/wEc�9Q��� W�L~��O��������O�}��ŷ��W�
��� ?e���Q;�F�Z�v��P;j�C�thM��v:oq��oq����v���ӡv:>�㳽����[�F>�S�*7���U�=,rAS|[4��WBgρzn��s&�������\Gޘ�&��8<ǭsxΫT�U��3p��1���gp��X���`;_o�}f���r��q���73�g�g�73�q8�q��9���g��v|�s��p��mJ�|wɣ�H�</~�=@[���?'9�INr��6�/h�Z  