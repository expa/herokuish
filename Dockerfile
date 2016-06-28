FROM heroku/cedar:14
RUN curl https://github.com/gliderlabs/herokuish/releases/download/v0.3.13/herokuish_0.3.14_linux_x86_64.tgz \
		--silent -L | tar -xzC /bin
RUN /bin/herokuish buildpack install \
	&& ln -s /bin/herokuish /build \
	&& ln -s /bin/herokuish /start \
	&& ln -s /bin/herokuish /exec
