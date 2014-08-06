projectName=selenium-service
fakeRoot=/tmp/$(projectName)
main:

clean:
	sudo rm -rf $(fakeRoot)
	sudo rm -rf /tmp/$(projectName).deb
	sudo rm -rf build/$(projectName).deb
deb-package: clean
	install -d $(fakeRoot)
	install -d $(fakeRoot)/DEBIAN
	install -d $(fakeRoot)/usr/share/doc/$(projectName)/
	cp ./DEBIAN/control $(fakeRoot)/DEBIAN/
	cp ./DEBIAN/postinst $(fakeRoot)/DEBIAN/
	sed -i 's/#build/$(BUILD_NUMBER)/' $(fakeRoot)/DEBIAN/control
	cp ./DEBIAN/copyright $(fakeRoot)/usr/share/doc/$(projectName)/
	gzip -c -9 ./DEBIAN/changelog > $(fakeRoot)/usr/share/doc/$(projectName)/changelog.gz
	
	
	
	sudo chown -R root:root $(fakeRoot)/
	sudo chmod 755 $(fakeRoot)/DEBIAN/postinst
	dpkg-deb --build $(fakeRoot)
	cp /tmp/$(projectName).deb build/
deb-package-test: deb-package
	lintian build/${projectName}.deb
	sudo reprepro -b /mnt/repo/debian remove wheezy ${projectName}
	sudo reprepro -b /mnt/repo/debian includedeb wheezy build/${projectName}.deb
	sudo apt-get update
	sudo apt-get -y upgrade $(projectName)