deploy:
	mdbook build
	cd book
	git init
	git config user.name "lujingwei"
	git config user.email "lujingwei002@qq.com"
	git add .
	git commit -m 'deploy'
	git branch -M pages
	git remote add origin git@github.com:lujingwei002/learn-rust-std.git
	git push -u -f origin pages
