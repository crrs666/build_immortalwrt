define Device/qcom_ap-dk07.1-c1
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Qualcomm
	DEVICE_MODEL := AP-DK07.1-C1
	DEVICE_VARIANT := 1GB NAND
	SOC := qcom-ipq4019
	DEVICE_DTS := qcom-ipq4019-ap-dk07.1-c1
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	DEVICE_PACKAGES := kmod-rtc-rx8010
endef
TARGET_DEVICES += qcom_ap-dk07.1-c1
