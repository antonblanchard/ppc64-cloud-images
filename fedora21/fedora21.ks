# System authorization information
auth --enableshadow --passalgo=sha512

# Use text mode install
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=eth0 --ipv6=auto --activate
network  --hostname=localhost.localdomain
# Root password
rootpw --iscrypted $6$MlktRkkL5SKrQ0ZJ$pmLvgkRcH4l6y6vYhpniJS1wp2cvQQ99jXeKZCTYSam2F4jpQcP6J.0joMff732b3J7qjglW/Mt19MMxbsLQO0
# Do not configure the X Window System
skipx
# System timezone
timezone US/Central --isUtc
user --groups=wheel --name=fedora --password=$6$uzp.Dmp35H2f4Rxn$lqahBFnqJW4yNcCx0veCG9bFbKdDxpBBufYw6bNYOVoflau2ClE2AaqFI.3e1PiI3X9BsHj/Vk7.xRIBL2Fb21 --iscrypted
# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
autopart --type=plain
# Partition clearing information
clearpart --all --initlabel --drives=sda

%packages
@container-management
@core
@domain-client
@hardware-support
@headless-management
@server-product
@standard

@development-tools
@c-development
%end

poweroff
