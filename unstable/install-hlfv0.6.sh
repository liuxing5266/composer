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
docker pull hyperledger/fabric-baseimage:x86_64-0.1.0
docker tag hyperledger/fabric-baseimage:x86_64-0.1.0 hyperledger/fabric-baseimage:latest

# Kill and remove any running Docker containers.
docker-compose -p composer kill
docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
docker ps -aq | xargs docker rm -f

# Start all Docker containers.
docker-compose -p composer up -d

# Wait for the Docker containers to start and initialize.
sleep 10

# Open the playground in a web browser.
if [ "$(uname)" = "Darwin" ]
then
  open http://localhost:8080
fi

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �hY �[o�0�yx�C �21�BJѸ)	l}�B�Gnr.-���g��U�6M�O"�s�v��96�om�[��!j�\���@�$�ٽyՁ�;CEXi�M؁�(��
l��-X��C)��I �D�Lpx^���?%A$ľ'�j�z"�`�� .rW�G���]s�d���8�^#"<�+��zF�t-R�R�YJ0zLG>�� ����ev��6�%������(�(�E��e�����)���Xt#�TF��5=[�DK�I _�9@��)ZȢ�����lͼ��l��Md6�7+��TŘ+�j�UѴ�B�]��ǵ��	M�`>M�n��'Y��$�=�N�s#�����l8M��XY*��@�YK>?ti�J��#C��� �������oՏ�?�)��:���P&Qg�1]W���(,�DG_UE�N�WS���JO������u[���[�:���.�o#���߉]����x���ir��	�c��ď=�����5�٥V��l�N[����d>�h����h(�O{ ?O T-����fN�젰*�T�q^vh�C}��"j?j.O6
-��	&�;&ܦC@Bw{q\D�����-�-MG�|�j���C���!�A6�
6��8�>�h�Cv���tkXt�4|q�K�!�cPQ��]�*Ջei��đ���D�K�-ʉr�����e��ļ���ⴐ_c�(����S=�Ջ�ӿ�_�p8���p8���p8���p8�o�X��D (  