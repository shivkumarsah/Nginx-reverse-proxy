#!/bin/sh

echo "###################################################################"
echo "## Installing Nginx dependencies and modules"
echo "###################################################################"

set -x

dependency_install() {
	cd /usr/local/src
	yum -y groupinstall "Development Tools"
	yum -y install expat-devel
	yum -y install libxslt-devel
	yum -y install gd gd-devel
	yum -y install perl-ExtUtils-Embed
	yum -y install openssl
	yum -y install openssl-devel
	yum -y install lua-devel
	yum -y install gcc gcc-c++ zlib-devel pcre-devel
}

pcre_install() {
	cd /usr/local/src
	echo "Installing PCRE 8.34"
	wget http://nchc.dl.sourceforge.net/project/pcre/pcre/8.34/pcre-8.34.tar.gz
	tar -xzvf pcre-8.34.tar.gz
	cd pcre-8.34/
	./configure
	make
	sudo make install
	sudo ldconfig
}

luajit_install() {
	if ! test -d /usr/local/src/luajit-2.0; then
		echo "Installing LuaJIT-2.0.1."
		#cd /usr/local/src
		#wget "http://luajit.org/download/LuaJIT-2.0.1.tar.gz"
		#tar -xzvf LuaJIT-2.0.1.tar.gz
		#cd LuaJIT-2.0.1
		#make
		#sudo make install
		#cd /usr/local/src
		#ln -sf LuaJIT-2.0.1 /usr/local/bin/luajit
		#export LUA_LIB=/usr/local/lib/
		#export LUA_INC=/usr/local/src/LuaJIT-2.0.1/
		#ln -s /usr/local/lib/libluajit-5.1.so.2.0.1 /usr/local/lib/liblua.so
		#export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
		################## Git Lua ##############
		cd /usr/local/src
		git clone http://luajit.org/git/luajit-2.0.git
		cd luajit-2.0/
		git pull
		cd /usr/local/src/luajit-2.0/
		make
		make install
		#ln -sf /usr/local/src/luajit-2.0 /usr/local/bin/luajit
		export LUA_LIB=/usr/local/lib/
		export LUA_INC=/usr/local/include/luajit-2.0/
		#ln -s /usr/local/lib/libluajit-5.1.so.2.0.0 /usr/local/lib/liblua.so
		echo "LuaJIT installed."
	else
		echo "Skipping LuaJIT-2.0.1, as it's already installed."
	fi
}

nginx_download() {
	mkdir /usr/local/src/nginx-master
	mkdir /usr/local/src/nginx-master/nginx-modules
	cd /usr/local/src/nginx-master
	echo "Downloading Nginx 1.6.3"
	wget http://nginx.org/download/nginx-1.6.3.tar.gz
	tar xfz nginx-1.6.3.tar.gz
	echo "Download completed."
}

lua_module_install() {
	cd /usr/local/src/nginx-master/nginx-modules
	mkdir lua-nginx-module
	cd lua-nginx-module
	echo "Downloading Nginx lua module"
	#wget https://github.com/chaoslawful/lua-nginx-module/archive/v0.7.21.tar.gz
	#tar -xzvf v0.7.21.tar.gz
	#LUA_MOD="/usr/local/src/nginx-master/nginx-modules/lua-nginx-module/lua-nginx-module-0.7.21"
	################# Downlaod from Git and install ##########################
	#wget https://github.com/openresty/lua-nginx-module/archive/master.zip
	#unzip master.zip
	#LUA_MOD="/usr/local/src/nginx-master/nginx-modules/lua-nginx-module/lua-nginx-module-master"
	################# Clone Git repo and install ##########################
	cd /usr/local/src/nginx-master/nginx-modules
	git clone --depth 1 https://github.com/chaoslawful/lua-nginx-module
	cd /usr/local/src/nginx-master/nginx-modules/lua-nginx-module
	git pull
	LUA_MOD="/usr/local/src/nginx-master/nginx-modules/lua-nginx-module"
	echo "Luajit module downloaded and installed successfully."
}

develkit_module_install() {
	cd /usr/local/src/nginx-master/nginx-modules
	mkdir ngx_devel_kit
	cd ngx_devel_kit
	echo "Downloading Nginx devel module"
	wget https://github.com/simpl/ngx_devel_kit/archive/v0.2.18.tar.gz
	tar -xzvf v0.2.18.tar.gz
	NGX_DEV="/usr/local/src/nginx-master/nginx-modules/ngx_devel_kit/ngx_devel_kit-0.2.18"
	echo "Ngx devel module downloaded and installed successfully."
}

nginx_configure() {
	echo "###################################################################"
	echo "## Installing and confuguring Nginx"
	echo "###################################################################"

	NGX_DEV="/usr/local/src/nginx-master/nginx-modules/ngx_devel_kit/ngx_devel_kit-0.2.18"
	#LUA_MOD="/usr/local/src/nginx-master/nginx-modules/lua-nginx-module/lua-nginx-module-master"
	LUA_MOD="/usr/local/src/nginx-master/nginx-modules/lua-nginx-module"
	#export LUAJIT_LIB=/usr/local/lib
	#export LUAJIT_INC=/usr/local/src/luajit-2.0

	mkdir /etc/nginx
	mkdir /var/log/nginx
	mkdir /var/lib/nginx
	cd /usr/local/src/nginx-master/nginx-1.6.3
	echo "Installing Nginx"
	./configure --prefix=/etc/nginx --conf-path=/etc/nginx/nginx.conf --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-log-path=/var/log/nginx/access.log --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-http_auth_request_module --with-http_ssl_module --add-module=$NGX_DEV --add-module=$LUA_MOD

	echo "###################################################################"
	echo "##  Nginx comfiguration completed"
	echo "###################################################################"
}

install_nginx() {
	cd /usr/local/src/nginx-master/nginx-1.6.3
	make -j2

	echo "###################################################################"
	echo "##  Nginx make completed"
	echo "###################################################################"

	make install

	echo "###################################################################"
	echo "##  Nginx instalation completed"
	echo "###################################################################"

	unset LUAJIT_LIB
	unset LUAJIT_INC
}


if [ $(id -u) = "0" ]; then
	dependency_install
	#pcre_install
	luajit_install
	nginx_download
	lua_module_install
	develkit_module_install
	nginx_configure
	install_nginx

	export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
	mkdir /etc/nginx/conf.d
	echo "###################################################################"
	echo "##   Installation completed successfully."
	echo "###################################################################"
else
	echo "\n\nPlease execute this script from root user\n\n"
fi
