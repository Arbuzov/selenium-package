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
	install -d build
	install -d $(fakeRoot)/usr/share/doc/$(projectName)/
	cp ./DEBIAN/control $(fakeRoot)/DEBIAN/
	cp ./DEBIAN/postinst $(fakeRoot)/DEBIAN/
	sed -i 's/#build/$(BUILD_NUMBER)/' $(fakeRoot)/DEBIAN/control
	cp ./DEBIAN/copyright $(fakeRoot)/usr/share/doc/$(projectName)/
	gzip -c -9 ./DEBIAN/changelog > $(fakeRoot)/usr/share/doc/$(projectName)/changelog.gz
	sudo chmod 644 $(fakeRoot)/usr/share/doc/selenium-service/*
	sudo chmod 644 $(fakeRoot)/DEBIAN/*
	
	install -d $(fakeRoot)/usr/share/selenium/
	install -m 755 -d $(fakeRoot)/var/log/selenium/
	cp ./scripts/selenium $(fakeRoot)/usr/share/selenium/
	cp ./lib/selenium-server.jar $(fakeRoot)/usr/share/selenium/
	sudo chown -R root:root $(fakeRoot)/usr/share/selenium/selenium
	sudo chmod 755 $(fakeRoot)/usr/share/selenium/selenium
	sudo chmod 644 $(fakeRoot)/usr/share/selenium/selenium-server.jar
	
	sudo chown -R root:root $(fakeRoot)/
	sudo chmod 755 $(fakeRoot)/DEBIAN/postinst
	dpkg-deb --build $(fakeRoot)
	cp /tmp/$(projectName).deb build/
deb-package-test: deb-package
	lintian build/${projectName}.deb
	sudo reprepro -b /home/repository/ -C main remove squeezy ${projectName}
	sudo reprepro -b /home/repository/ -C main includedeb squeezy build/${projectName}.deb