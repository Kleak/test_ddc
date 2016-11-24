all: gen/test_ddc.dart.js

gen/test_ddc.dart.js:
	dartdevc --modules=common -o gen/test_ddc.dart.js web/test_ddc.dart

clean:
	rm gen/test_ddc.dart.js gen/test_ddc.dart.js.map gen/test_ddc.dart.sum
