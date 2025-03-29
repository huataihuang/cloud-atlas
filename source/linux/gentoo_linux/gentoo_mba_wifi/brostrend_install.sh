            a69c:5721)
                _DRIVER=aic8800
                bold "Switching the adapter from storage to WLAN mode"
                # Background it as it can take up to 30 seconds in a VM
                rw usb_modeswitch -KQ -v a69c -p 5721 &
                ;;
