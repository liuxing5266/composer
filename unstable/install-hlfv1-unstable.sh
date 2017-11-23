ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv1/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��Z �=�r��r�=��)'�T��d�fa��^�$ �(��o-�o�%��;�$D�q!E):�O8U���F�!���@^33 I��Dɔh{ͮ�H��t�\z�{�PM����b�;��B���j����pb1�|F�����G|T�$Q��Ǣ�p���FpmZ <r,�����f���E����&X��FVWS���0 �c�����/Á����l��a.��ڰ�Ӛ��t�6���E혖c{$��n��$��9=�j�\ա�;":s�e@}Pl\��>.���K�:�Y�RQ7D:��Ƚ� :�K��?����bq��"�?�t�L��\��������=#K��vs^��������B��D<8>.
��!��HM3"5h7�t-v�)PT��j�k����\�y_ޯ�R�7ܻK<c��?�NO��"�u��e9Q0E��������IK�_,���)��X:� !KVۚ����|����_�.�r�_,���)�߁J���S�4��������O��1Q����` `������:�u��o.̅^��l��:������@����1iY�6��gR�.�@ݴ �t��F���N��"{:>ߎ�u�R��;��h��p��V�^�� ���͡�p�k�$��8{3�9M�V�vd��c��&�q�K��NӴh�H�%<�tMA�My�Xk�($�9/���=�Rm���)�x eM7��҄�1H�M�%jA�QJ^#ۣ��\MWC�R�Zٴ�����k:ao�FHV�Q�p{�Q*2hLB�O�p"��!��ƹ�e�aѯ� ��������%p��\.W��n���u=MO�ug�Ν���x|9�/���+�]C!�p��-M�4T`���E8�5�h�lfX�v���g���[�OU:�@�����k���[�e�������4M��b~�6�l��a�Qx	"x�FW��Q�ǁ�I)3u3ƙ� w�Z�%R��۰�ڀ�:�{IZ1;l@3�j����=�I[�C�mv0���i��fI`�H�#���1����s(�S�t�)V�i�:#����S�A�N� ����A��S��1�9D\�;رB��>�(&Wt5�"��&��w���<��btml�#����4�I-������zJ'���F�����6g	3���@3H������X�D��\�8�� ��Quz@;�/F����^Ӽ�Z����Й���Ȇ
��Z.�_+LY��@���_w���I��r�_,��n������'3���ؤ���r�g!��I��>�g�y�t�f��G�1��Y����y6�kY� �4��cZ}&�+m}�l�Tvr���T)wP��OM�/Ʊ���]�w�V/ȗkD$j+�α�����\��a�T����]��f��C �\�F�:��m�M4�z�g1�	\��X?�6��&�H<����,,,qT��[�ȥ��J.�ٯV��zm����w�j?�R���[��Ձ���Z��.�x�|u�$` oހթ���V-޽C��ږ׊�	
���p�5d����j���%m2���:��7+dx�]����"���(��(b��5���'w`�dOq��`��'Į���p���� ���z�T���&�:�����
����e�A��R����]�7�,|E
��0����s��,���ܤ��
K�_ܿ�3O>��{bt�@3p��:���P���`!Ǆ��K��������4?����yNX�/f�?uq����A���?��Ǔ�?��x�m��s)`���N���hl��/&�3�7�[��e��:�X�����64T;�<��d�G9��(�k!F.�v�~u�j�z�6Q����0�r�u���}���`��o;�H���2��E6*�*���nE�P}"�\����0�B&"yg���@�I9�yb�AȪ�?G�à$\�bl
Q��WF{�B*nU�v� #]��*c��!x<q�Lf���c�k�|�k3�P��f,M���v���RȬ�?.N�G�����������Ys����뇈8��ͥ���N9� �޼f�@�t0����M� ��0g�+�N�
2�w)`Zط��D��4��X������?ϥ���u}��ii�-f뿯�s���?�f
RZ^����5�	�a�@rn�G���d�X$�gM,����r�8�f�B�`�B�0X��T��
?��3�(�r�{�9�[�W�  �r��M�ꯃ�p�:5�������ڠ��O4��^#r�C0��(�Tm/r`��i�էW+���k̐�'g!���5a��7�p6&I�"AZk�	Ȇ�>�O����B���5������,x	"N�C��A��[%�u>�w�����G�%�s�(�Å�H ��Q6#jQ7M�ٌsǂK��Χ�@�>v7`��Ȯ��R`ش|��vGG��f/}Zd���F�Y胋W�ji��F�A݆EP�����b-�?�z+"�{�bg?������KhC�I>F����$7B�|0���L��9Q�c.��sP�ʕ�������
/��c���5"��0Mhh理EF&�9��d!�+�/W2�`\e��7��"�5�c�:��7��F}#��X�P�EdSiC��9�q���qP��{�Ť2��B����At�:��wP��&A��O� d���U��6�Ѳ*ұ�>�4Q�qTo��t�!wD�2�H��y=Ԣʣ�@Ҭ �R�����H�L�&�LH��i�¬Rx�}��S�@2�RO@VJ	/+x�F���,s�O�/����7OP�,�O'�A�.����g�����@j[��F��:=B���|̞��%c��Q��x�����qAA3��&�_���_�y��a�»�G~��>����>vj z�({?ؗ!5�L���%v�5T�3e �ᵅ� ���N�j���5ܯ=s�n�j׸d���w�nr�(���c,v�X�#�����ȼ�F�:<+���>�%����[�[����#x�%��[��8�|��B���?�ļ�)���A:���pR|��O����� ��2�w�}����������k�&֟�~A�����ب+�	X��Ee#���k	A��<cb����
R"����Pې������˷�$�y�_���;��cCd�Y���+���<�~�aR�a�����?��#�2X�F����7+�f�ȿ��7#:,���n��+������n��������͑��W�^�����o�	A�"Ѧ?a���y;�?u�{pw���x�}��r��1��?�)���p��E)[������b�=ʮWCSq���`-S'��"��,�c�A�ރ�X�����ۣe�Ǉ3��n^���C39��8}�2��f��]��CHL<D ��� 9��es)����o�|.��>M�d%Ր{���ȕ䂻o���Hr�o��kf��{��qn�<ɝ�r��S�3{���ږ�j&�̧�g�s��l1�J�Uhֶ�v-�ʅG���\��J��i�����κǂ~~,l�mW���Y�l'�'���u�Y{��O��iM��v�2�p�Ph�5��S1{;M���(��iN�Wr�~%'��S����G��Z�h�R���a����:��g*y�p�v�d~�(dmxt�U�R縒9�'�^���FUȺ��I��H:�����L=��(����J<�d�F�,�h;�(�g�^�ЭU�'�%���d��v9/&�Ff;���2;2�������Y��o��ʕ���׍^kǻG��K�v8*U^%w����a\/U��pW��B��iR>~?����r<g�ՃR�D������J%���E�XZ5��$#�"��FZΓ��)�r}##��r>e�Z��^��O�ʹd�:�n<�K&�Vi���m贱����ť���&��v�(w�9�����5�|���S��[��5R�ƇZ���<!%"M��y<��P�8��ݔi�ei7f�����53����[~k�>��@N��D���%y�A�|�������e8���g�=�h=����Z?��zi��x>��������o��sެ�/>r��w��G;~�/aA�?���N��Dy~���I~������L>����d��5:��� ������z{{�]S�$�V-��9ٗ�2���t��g�H9/��mb�+%�%�����B����γ0~~(�S������U�KR_��H���Z#�<2���V�$@E���n/�S�P%�M3�z�W���ԭ�����_���3x��^&�� �����/ n�y�$f^/���Ib����y]$f^���Ab����y�#f^�9b��F̵���w�<�?��'-��E�'���ڧ��}��0��[��g!���ɽ\*��e[�L�xǷ�Rrqh�墒.6����L6]�����QÍ�<z����v�1c�gO��V)n��{�-%��)��~ww�u�Nېz����θ�N�hTr0-7���ܤd���~;�����[�%z��Ǯ������?,�����[4.>���_V'd]%�f���B3OH��A�uh�{�M�;˫k�����`<��?���}/u�j�,�4�k�F#f�:��]�mh��*�G��T�/�S��<���K���< �(��g�8 �6�P36A ����7oB�-w�B{���rEZԐn�h*�j�}���H*��e�;��x������A}o=�Id��$5~���?6r'��z�>��A.Y�{N�>�x�&d���=:��x7��*B$2�\g }ӵ|z�B�Zt\��c@o��y�Q�a��i���:h��F��O�V�<  Z��$��X�1�^Fi}�ۦ��1��3^*t�׷'����jؽx*M����AY64l�}/���:)�f�ፍ��tʀ�3*Y��b�_=r�}؂&�y,M�W�ǁ�Mp��}���՝u�w�qc-v#��A�//���7�//���囹�km�?n�.�]\A�]"��4yH�5��
�<ׁ��h]���6���d��M�im�S�>`q�5w>��{�
q�-�1�s�!�y�
��t�>F���{�G��ff���v�·�]L��vf��O�-m�3m���o�\6�R���r��r����A�!��H���� n �!�����
����!n�""?N�\���i*FS]���~��=IevvI����n��xs��v������@H#��c%�Ѥ4��'"6|F�^��K B<)���g�Ĵ�!�i5�λ�C�Oޚ��GD�v]k��rM�����x�C$	��J~�s����WcU[�?h��?����If{�+ kr�3�s`�H�`�?|�A�UPv���!��A�F3g'0Ŝـ� �Ɓ&X�˖3���,݋d[�t}���7:ėem�]�� �(�9T`���C�W,�4�{��q��Že���� �Ӿ�5� �VG�|?����e��cP�G��#���b��|���5.)
�fǏ�4�TQ�1D<tkzC=B��Z�K6����kc ���(��m\��'RI|{��&����������g��y�~�_Z������'�_h���>���������_c?$�O���~�ދ�����{?AoE^�^א�IC��{�t2�T5	�RI5��hD
O�2��$rZ�J�2��Q)%GR�U	���R6G�I�Eʱ���������[�?���'���O�l��>�~��'��ñ����c��&������7c�s�������C��}���Ǿ&�����~��c?��7���DC\�7�5�6
��lY�����c�s%��O�.������'�z���'�
^c׽;�����qO`��@h�3������ vIn��.Hk_TW4)�t�I�Nz�[zy�0J�"�����zW��CQh
.����	��,&�Qn)�́��}+q.!�!���<�GՉBV�Bs�\T��[0`�ʢ2:Lu;�+۳.�s���uT�ŸE��ۢv��A56l�D�˰�����W�%3R+��D%as=�q����> VNu��ىi��Cj�F�Y���`U(T�-�ԝk�f;
R��
���n6�:�(%��^	t]����t��1���.*,z��.��W�ݩ7R�7��䘧��K���D�T:a�2��Tz����e�;���Զ�� �4��ӓ��>q���邃-rY�Z��vz��ORy[U���2��|��T�TZ�wZm�I�Yz>��bm���D9����v+q����?����J�J�zF%�ױ�[%���R��?^J(-���P�p�#�h易��V{��̏�g�����5.��Z\�0({>���`�P�^[�`P�\O�d�h ���[�p�t=���h�_�ӳ1�,fʳ�!+{=��t�L�#����9/�V�S"����6)�i�Í�N�R��tM5W?��5q-�O5җ�,�?�"~2=�����\
��\���WG5�6S��D��\Bɨ|�M���B��\��f\!�ֈQ��)�f3m�-��=g,��S��0��G�=g�jiHj\�vph�۽vm��1�R���G�lz�]@e��D�����/�{1�V�^���K�^x�*|��ka|����5�w�W������/7��S�e�2�~�{_����ୄ_.���$|H�}x���c�{�//�^��v�j�?|�e�~�V�߾�E.�b?��?���?���������̿���UV����Z��Nv^m��3�e��4��j_9#�%�y��K���'��^qca9��$�8v�Y �3�\�u��(��<��p9�g]��́��p�d�Q�*JG�EFW|a�3k�!0���I�i�̊(�2�t>]�c'u�p��r�z�3?Ps#�Z��-�#��3J�ΏdM�'E�Y�R���wVG�BY7�I��"�.v$�5��d��GbY����2z����,]���HCfZJy�*�7&�H2�����/���2G*Z��-�l�в��W��!(�j�f�6h�H[�GE�����E�(�Հ�㔜hأa�U0���\3'��`�Db���A���z�q�ß�S	��Vb��3��E���ߺ�h�PQ�CE��-'x�=j�J��Vj�>4Wg�����������l+ȅ}(��:�#R�:bE.)��e��[V��jZ ����0�=<�*�cץ���1���]�{@�+�9k�&±�rUN�NT�6:��3�%�^��ݢ-Ϊ�=�1��j%�7���D�
C6�1͊���樗#������q�ȟ�*�nuO�U��w�p�h�S�9OQ�4�x�r��.o�zg�(Ko�S�^(-�ٟ�e:����#��)��eጨn��?�iv�e�Z�w��K���V'\����1&��ݑt��Ң��謘�K��0_2x.C����u�Vn@�8��b�AY����t⿺�&�"$˵ ��Qc2>223��1u %�3Z�+��+H,�H��dQ�G���Pt�0��{l�_(L$��I��@��{��J�<N6ڇ�A~�g��V���ԁ�q�)Wć.o�����-^'�՞8!$�ε���8��6�m�pPL���ln`��`
%�u
H�%Ӯt����8�\I#���m��y�Ԡ�N4r��Sl(�����yC�����2��*Sy1#(��C�D��(�����2IJ#���a2F;!1nk��g�Hv&�p+��%ؔ�{=��k�X��]DL�^�\�ľt����ע�[X��ƫ�I�U�+W
u�_����hS����݊���*���4W�3[\N���W��m˴�"��c$G���{#��=���O�o?}�|{�=Gy���^�^"מ}>¾��;�C�4Tχ���tEoB�z%
��=���d��N�� FP��|�����h��H~���M����?�����šUu�ٶfǨ��m��)z��<:���Bf�����]�<��О�Y\���K���t���������t3��P��j?�]O�=��F��!���n��Sa�Z\CQ��� ��� ����TJ��i*�4���@4��4��L����?"{�|�&Di>�-z����~<��]g������?򿰞U��Q`#t�f�8�Ǐ֧=���5�f����gA^�bتo���D���N��h7,q�cj"_�==��7��-�$h�!��QKPϠ�7��?j=,�q�1�|�,�M��~��J
�h�3��kdLEoշ�9�Dz��Mǁ����G���������T�c�,8(h���3��3o��� d��|m��l�,��4b	�ƣ�{;H❸�?���F��s�h�Ez�c������'u�Ȩw���k�1�����Ά�>�\�B�#5"�p#&~��y6
EA�?Ycض"��E��H���X�����j?�J�
{���+'�!��B��>$�P�����It��nX�cŘH�~�i�'0\[/�N|)��k/$�f�.��+�0���CXW�wTh��)|v��a߉~�X�o=�ME.��"J�kH��Բm��_��`6��?`ТӷME��pi��oѺ�����oqd�dFKȡ!qhg�gA��F��1l�8uZRB��7'q���ת�g@����=D@�Q�ɧ�8ЏǶ�U����!N�?ɚj&�l]+\7#m<M)d��������g�Ah��A*�����8���K��=� 5=C���\�!��}8��C�3;���Z�E���-�����x�E�q���4�V���l�OW2� � 2 �"T�˰.�=ُ��&tx����3�L{��z��D#h�2
�^G06$���^ݨ��HZ��hW �D���P��l����IZ`��G[�e0�3 �a������U��]��N,׳���@�뵩!�`X꺋�=^�8�	в�p.�h��H��[��7	?<���� (|S����c�A���}�Ed�M���n{���v=!A��9�t�i��ZC(@�Q�;0tT&.{�#	�D��ebG Uk"��"r��}7nl9��I���&��c�G�������y�jtт��nAN�1M��P:���<|����8�:�Xs\k:��Ʀ��ܙ��ȱ�RDpގ8��������bG�z����g>�;���6.y�Oe����T2��;����ޏ�O��a��Jv�\�x%
�����pdó~g]��&�?���02ғ��(���|��Q��5�&��J;:��sQ-xyV�+Wh|�k=/X�p�gkG"IU�'��LJ�Ler�&QI-I��龢h}B��	I"�$�?G�r_���R*��$2-���h ؋<n#lya�P��h������xo��AN���WŎ	'̃9Ԗ���Ir��dY�SY<�J*Aj)�r�$�ө����鬖�d���`&�9-��)-i`b�d/��>�9q�T/���m#-2]��=��"%��:	����;�]X
��쬿��%�׸�֚,�X]�\��Wj�
w�U���<��/ƷD�J�l�k���H���-�m�-�K5�	:꿤�n�
N��y�v���tEh�y�I�x��0��.�����s�{�#;V��L8	݂�j	{�$t��d�Kg�j�h;n�}���P�,�ӵQ���0��x'�l��3Z�}@��/8L9�a���{��� ��j��q�-DG��%���k캤G,Ǵ��E�c���k|U|2��D"�Y'��41��}���OT6~0��ӣhـ�ΙMt���7��? UK����U|�ʉ�Z�@ �{��q���f���H�-r=�uZ,����X֋��EP�%����'K�4C��'yk�X���Z;_bL�_�)��*�S�l�h�%��0�?{��䓾d��9$Ll.�7��N�G�!�o����+H>t6�؍l�)k���.�c����O��M��j�/w���|���(�����/w1�	@ls�����F��e���
hb;p*��i����ٶ��������M޳��JQ8y��6��\��4���g^�$NB��w��鹯�}��O������F�R��������;�߷�n���V�넍�K��nc����������e��$�o�*������n�����_	|���M���/��Em��B����Vҝ�;4wh���/���)})�?jG��;��V�m�����.���Y��ɪ�)W�~�R4URr�,�h�,��'�$�IʙTV�qU#R���7��_��e��'���/y��VRD�����������wm͉�]��_��[5�Oo��IEE�7_"�(*(ʯ5�Lϴ�$�� ���*�ʤG1�Y{���3��y�M=v�Hkl/�hWws\���βpx����簍��Y�?۰�;;�[��~���1��	��+|��FxNz���%�`�f�C4�IW���^���;4�����_�t�x4����>|<�?φ��:�Q��������W�&�?�=��I��*P���l`�/�����~��������������6�]�[���_;������4���Vqo�@�U������f�����������hu����m��"�{�g��_�N������G8�����O������m���s�F�?}7��_���Z�P�����'�����߼������O������wC:[9�x��Yֲ��b���i�V?����}ѻ��w?o����v?���|3��(���}��}"k����(s�u�RK�w7��~���Lq鼰��]��en,UG�%Y�B{�3'�nk�#˲�6N�/Nag�0�����{�/k����}v�<ٳ�u�\9����o�G˔bN�:M/��v�X���?�}J��
M�U.�<%�s��s	]���Zю��y �J��$�3M�f���r���r�i�3������m1:7�,�w3����_���D��P�n�����mh�CJT�hD�� �	���+�?A��?A�S����G����Y��]���s�F���g���O�W�F������ф����ë������������O�,�if'���;������KY_���E����G^���]gǶ��O�U?	'���������h�Z��m���d�Q�_lX�UP}UT��J^���YP��x�wX`u�#�0t%{*둿�����S]�<�H� �sI�%�PS�om|䥏��6�u��#S]
ݒ@4���Ӫ�f�m(��v�\�3� �h��`��L2��£�(����\~�Rd��U^��4����Ƙ����������W����%��C����s�&�?��g�)�����I�?_�8,h|`>�9ڧ8�y����9�.H��6 H?�Ȁ	h�'},�����G��Q�?����g��ge��V�XL�h5$K3�t(��n#�-�TtWm}�����%��丹�=Q���W��1���\���vd�컇��<4O�6]n���gV��H�e����%L���訓����ͻ���V4������P���'���M8��������������kX���	�����>����h��}Ԕ�i;���B��h�;�q���lW��
h+���K���If���h�Ƭg\2���^�#Kt�,
+$��R�:�FQF�Tv�V�bwql��dS0E'�"`�ھKC��V4��'���	8����;����0��_���`���`�����?��@#����?��W^�ny��5�QyG�𸙲���+�r�����W������%���e�Um-� ��?p �W=����T:�$X	�*r���; �H���	h����V�[b�����ڨ��
��ޮ,Ku�2 Z�1�Ym*(�K=ϗҹ�ݫz3+�ȷ�U���}7����[����nw �N[,t�Z�Hi�W��7\0 <��F�04:��(�^�^(�$R9ΘHk���e�=o ��R[R{+&�T-?jBB�����4�bJ�2�0�pܵQn~앁ؚʹ�ǳ����H�,��1��V�����GC+��d�$ߤz���{}��Y4ptrY�=m���h���S���
|��x0��\T��_��a��4���Gh�_��}���+A%��~�EU�����4K@�_ ���!������a��&T��p����}�8��{s�� �x����C�.$=~��#	b��!ņ��x!,v~�P�?��}��@�}<~���;���R�9�l�tm�c���,�4�c�d�JM:�2�k�d����ŲJj��[��b�}�;���ݐ�`o��t���l&�1�	����`FǮ�8ߟ$�r��a���6���M8�q���?��T����[�Cݯ�O������g
��*��g�������7�Đ��D �����q����_E����ۗ��vpCP�o�;���W^�������ql�F�2G��%��q���n�;(k����e�[!�%�#�߷�!?2�}ke#�:�]s2ʽ	-<�T�.���w��ig��;�e��b�i<�&+:g�%2�=����'c69���	Zۛ[qL�˺�B��U3}>1.�\:Q��l[���An�\�9���l����qnqsp�#+�"�F�u�m����70���1ѣ���鱗#AWI5%*�L��h�۳�⼒�'<�ܺ-VV���N�b̟�9��EkL�1z�y�N�����γG�������D��in8#��cٕ�	�����ߚP����ݛ
��?��k�8	��5�Z��A�	����o����J ��0���0������$�����s�&�?���C����%� MA#�������_����_������`��W>��?f�_Z��<F��=�?	�%h�v_����U�*�<��B� ��������P3�C8D� ���������+A��!j�?���O?���?*A���!�FU�����?T������G8~��������6Cj���[�5�������� ����Є��Q�	�� � �� �����j�Q#�����������,��p��ш��A�	�� � �� ����������J� ��������?��k�?6���p�{%h����hB������a���������?�8�*� ��/Y�B(�k ���[�5���o>p�Cuh���U�X�2�X�ĸǇ��򹀧2���=, ),�p��xg=��(�f�?��O��&�?��P�ׄ���Ñ:�V@��)����ӽV�¿U�b+��7`���E�/ji����gw �1��Fg�$��-�A9��-q\�C���$e�c�v��.۞Ķ�1�����B���������3��8������G{@����/}�kc�&�e�K_K��U��04������P���'���M8��������������kX���	�����>���o�:}n��h����[�E(uW�y9�\��6><�a�l�/���s�h%F�R��MKu'G�\L�bw��g��V��3;��a�)��ݹ#�{]Hb��Fj�Q�oWåBP���8�����"4���?������
h��������/����/�@���������?�G�?迏�k�o����S���tLJ��l����N���o���������&�d����׏u �?r�w��-����eug;?º8��e?��n6F�v�;�h�`���h�(�V�J(˜�/��0.q?bvTI��gdz'-�{m7���ӷ���G'���M�-�x�,�Hi���;a%�ȫ���hC�s����e~�b��T�C�逴�A9Zv�,�bJj�=�Ξ�������'cn��z#�s��.��ou�kWbQM�$���^���h��9/i��N�Vxܓkt��������+��������#�������C��|��������$N��M��p�A�'�W����Jt��Ƣ�����Oa8�_������)��*P�?�zB�G�P��k����G]9��*��gؒ$�/_�?t�1w�i�u���G�w�v�G[������Y��g�M����^i�����S<Y~�{��x������Y(ї�o�k]z��X���uys.o�%�_cK&�`�Q��iUů��.��m���mI���keLbdHk�d�����w��	�	��\�R#B)[����fJ�y7��q��C&%w<�W.)�S[<�h�'+��}�f/����X1�)��Y��~����o�]T��>s92cQY�?��dK4�۲�B|�m3�ЮI�V!q���(�k�2GFW�EE�Ebُ-N�#�G�������Dpma:��C�A���C<�Z����zba�g�����.2��,1WAe*�خLxk '����^��G���A��"T��X��|'=�]p8Ex��p��m�	�F]f�X����L@X��b>���B�����k����g���L��n~T��������l������>3��ŜX�b�e��^��U� �+7���o�G�����w�h���
4A��,y����������`T��_�����?�_%x���7������9w�Y,���P�є�/�;�ϳ������e�N)�'��f�!������!?��ݬ?���T��o�����~��|?��s�k�%��GFbz-y7�+�!59is~�����n+�`C7֖#H?�]���.%d�bRN7�^����f�!���^l?����J��E�b�YtZҸŲ��I���/�m�ˉ��֥�!�}?!����p��q{�l6c��)K���k�a����f��]������G��6\RI�rO��D]�(4P��B�]���M�ģ��������T2�c�#�[�/`�_�l.|��p��8��{��ښ���S89�Sgʓ��N͞*@@�~�LM� �P�S���m��N';�b��W�Ĉ"�<�y�Z��-F�f%�&5���g�R��oH��������{{~f��Te֞L��֪�v;�ŉ���T7��J�2D�s`��<��}ݶ$��Q������������d��� �/v{����i��Z��+<f������Б����@�pPfHK��p����Y��T�������?��ؙ�E�;�]�.����ͻ����^�a���K�����>J'nxY���n�/E�OD<5���b�296�YY��M��r~���h�뗑+�G��.#W��ҕn�txq -��jב_W�{Y��O�Y8#��mmծ�ɉ�w���qݞ٬�ˑ�x��$-+�w�f8���i��m�Qڜ[r�Ų0mrLo�m6bp����5����x^�Qhp\T;��,x�)��zcwڔbK���^Y�<;�ok��4#��Vڂ�6�Ju��v;ʜkh��1.�My:4��h��<Q��{㋖����!V�n�s8�ҧJrU��B�QD����b�<'�*N�d_�Л�z���7�i����[����TH��74��
����������:����=2�_��d����
0����O��	����ު���.�L��}��,�?���#e��Bp#��U��8����T��oP��A�7����-����_���i|���S8���	�g��C�ϔHG����C��@�A����������
��?�D}� �?�?z�'�����SJ��������O�X�� �O���?ԅ@DZ��}�b���� �����_2��������
(�$����������U����Y��AG&�������?@��� �`��_���B��������GFF��B "��U��8����T��P��?@����7�?��O*���c���@���/�Oݨ� �R!���Q�����#�������d����� ��[�� ��&�������_��H\����CJdB��$�K�֌2E��L�ʤI�6��%�4ْIcX�^��-4e�e�-28C���˓�/2��?��O�����(W'��_�r��5����r�A���˂��8���GZ�7���sZ�̩S�+��/L0_j2��j$[�*��׼���VC�w�d���p�V�$��d�'��vP

S[;�(b�Ě�9S)|_`����V��uڶ$�����-�]o�qvI��J��//�:����I���#�?��D��?\��o�B��:���0�(����q��*�/Y�����3�?^�����mrT�8��|T6L5m{5i	�.�;{һ�5q�l͚��r����o�����4Q�a�p���X���۬�¶ff��K�����v��\mF.e�.ԅ@;���%�����7���/�_�L����/d@��A��A��?D�?��	�G3����/�Y�������_�i����F�Z��#�|��9�'M~��{>�
/�S���%���_v�a/{�8\��Ʀ;��8N�z��W{���g-���OF����[6��v�o�rl�6�xݮ�Z��6V��+jmW)��ߦ��B���G���y��UJئ���\o ��&��mQ�;F�1M!��|gPM��
����$%�M������
�د�|/-���)��8G��tj:[�%��lH��U&5�U���a��L��~�g�I)L�J�|D>��qz�Ҁ*���.���ZՃ�u����{I�AC�'T�u�����Q����5��_��(�I�?��x{2����/�?R���/k�A����������4� ��$	��s@�A���?q#��R���X���G@�A���?uc���M�,�?T�L������?��O���4���P��?�/��č�_������
�H�����_&��@Ff��DB&��:����T�f��)��О�?���o��o�cSd�cffW�Z?��#�:O�����$V`?���|��H>�3�I�����q�\r[���K�����N�	{�"�*�cF�W��)-:X�iS�}mV^��W�I5���ԩ��ֺi���)�%kt�%�vO&i�؏��^�~�y��.���l�Xr^�Y6��͖S�ñ2�z���S&�W�n��r��<.�cY'���z=$�9f��%[��B'X/����6���ÃN�"
s�5����O�n}�,T�`(�U��v����L�?�Gr��bp��������_&�����%�|� �����F�/��S�A�/��������� ��{^���K ��o��	��q�DdH�o�: ޚL��0�ߊ�+�d������v��U�!�w\�4T�v�1�R��������H�/�ͽ���xIS�� ��?�r J�`+��G�j�5���JJE3
�Q�i�k��6i���{fP��p�)��>	��Fq8/��t����zƢ���!�� ,I�39 X��G9 ݈���b�j���,z\�P�}%\��̸*6۲À�ϥ��w�{��w����)�j54	�����^�y���0y��f���_>��a2����@��T@��>-��J�'�߷�˂������i����khEֲ���%͜q��h\g(��I�$�R٤	��5�,�0u�1�%��1���~��2Y��[����t�����)�s(���'S�=aC?���F,��^0�v[����IX�_��<換1Y��������Gv�;���\�0yI+�ܳ�����g*s*9d~q���9��i6���X�,�c� ����p���,��P�H��d(����B��:2��0����i�8D})�,�?�����7ڭF󅤷e�/�p�RXR�h�7�^�JM�3)x|䄝�%�cz��[��
U��\jU"�^ј{���!�W�~avl��]��{��dݠ\��ګM���*���"!�{-�h������h�����������/��B�A��A�����C��Y�4]���o��Q��l�����ǌ�}�*�y|1
[ܽ�����O9 ?���X vY�e@~i;m%2�V�:y�a��jEA�w\�4�X�%sXn�}*c�B�XLKlxd������Ŗ�/���k��z�(M��m�_-~y���a���5.�v�|�x�J-��|gP墤O0���@⣆�e� v+a�$2>��=�y���]-���x���`�1����x���7wy!>��ҏ4��X]����(�O��~��p O!��Km�U�fӓ��'w�.�pǕ==6��������1J���20�a}���^�Iu�תS�3L�.Q���a�n��o�p����!<�������T��>��b�,���s�ts���B3��q������ᨭcE=x?�I�U���$ls��o�ۣ
v~]xHv���7��2s��/�u�
r�1��>lv�����X�>��>���z���(�5�5W�]	��ӓ��˝�'�_l��X��.������Ƽ��O�Pz��̿�3�1�G0������$�&���o�����;nAׂ9��-'�0�qs��a�����Ϝ�;n��V��Yk�,x�3�}0��{*fh���6r�G;�ĸ�P��_;W[�r��W�g���\87s����x3Ǐ_��XE�����?r�,��ox|����^�c�5�
�������������9/�ŏ�b�Oz����ł����:��J����wϭ��y8�W��"�'�f��>̒���Z?W=z��2g����wN.��o��e�kh��7��*�hk��s]ǵs�X��O���9'vf�s����n�c_i��A���^i~�I�n����`�1������kǂ�iz_��YK��ד:��9>��y����&^��O_^�3λ��������i<��/58��34
��W�4��<9Xu�_;����8�����C�Z]�c[����jJ��؞]D���}</S��'%/x���H����?�x�                ��<��C�� � 