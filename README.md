pimon
=====

Tool for monitoring some system information of the Raspberry Pi.

## Installation

Install 'rrdtool' and a webserver on your Pi.
Then:

	cd /var/www  # or every other webroot
	git clone https://github.com/ruester/pimon

Put following lines to your /etc/crontab:

	*/2 *   * * * root /var/www/pimon/pimon.sh
	*/10 *  * * * root /var/www/pimon/png.sh

That's it! Now visit:

	<Your Webserver>/pimon
