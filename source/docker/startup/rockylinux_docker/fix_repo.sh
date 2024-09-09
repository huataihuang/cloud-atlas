cd /etc/yum.repos.d

for file in rocky-addons.repo rocky-devel.repo rocky-extras.repo rocky.repo; do
	sed -i 's/baseurl=/#baseurl=/g' $file
	sed -i 's/#mirrorlist=/mirrorlist=/g' $file
done
