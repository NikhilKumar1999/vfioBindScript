#!/bin/bash
if [ $# == 0 ]; then 
	echo "Atleast IOMMU group required to be binded to vfio-pci"
	exit
fi
iommuGroupPath="/sys/kernel/iommu_groups"
vfioPath="/sys/bus/pci/drivers/vfio-pci/new_id"
devicePath="/sys/bus/pci/devices"
for iommu_group in $@ ;do  
	if [ ! -d $iommuGroupPath/$iommu_group ]; then 
		echo -e "IOMMU group $iommu_group doesn\'t exist\n continuing to next group"
		continue
	fi
	echo "binding IOMMU Group $iommu_group:"
	for oldPath in $(find $iommuGroupPath/$iommu_group/devices/* -maxdepth 0);do 
		oldId="${oldPath##*/}"
		perId="$(cat $devicePath/$oldId/vendor) $(cat $devicePath/$oldId/device)"
		echo "Unbining device $(lspci -nns ${oldId})"
		echo "$oldId" > "$devicePath/$oldId/driver/unbind"
		echo "binding device to vfio"
		echo "$perId" > "$vfioPath"
	done
done
