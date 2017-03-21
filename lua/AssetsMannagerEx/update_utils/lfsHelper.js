var fs = require("fs")
var crypto = require('crypto');

function geFileList(path, filesList, walkDir)
{	
	readFile(path, filesList, walkDir);
	return filesList;
}

var _walkDir = process.env.WALKDIR || "../";
var _outDir = process.env.OUT_DIR || "./"
var _excludeDir = process.env.EXCLUDE_DIR || ""
var url = process.env.URL || "";
var version = process.env.VERSION || "1.0.0";

//遍历读取文件
function readFile(path, filesList, walkDir) {
	var files = fs.readdirSync(path);//需要用到同步读取
	files.forEach(walk);
	function walk(file){
		
		if (file == ".DS_Store") {
			return;
		}
		
		var states = fs.statSync(path + '/' + file);   
		if(states.isDirectory()) {
			if (path != _excludeDir) {
				readFile(path + '/' + file, filesList, walkDir);
			}
		}
		else { 
			//创建一个对象保存信息
			var obj = new Object();
			var fullPath = path + '/' + file;
			
			obj.path = fullPath.substring(walkDir.length, fullPath.length);
			obj.name = obj.path;
			obj.size = states.size;//文件大小，以字节为单位
			var text = fs.readFileSync(fullPath);
			obj.md5 = crypto.createHash('md5').update(text, 'utf-8').digest('hex');
			
			filesList.push(obj);
  		}  
 	}
}

var filesList = []
filesList = geFileList(_walkDir, filesList, _walkDir);

var obj = {
	"assets" : {},
	"packageUrl" : url,
	"remoteManifestUrl": url + "project.manifest",
	"remoteVersionUrl": url + "version.manifest",
	"version": version
}
	
function write2manifest() {
	for (var i = 0; i < filesList.length; ++i) {
		var file = filesList[i];
		obj.assets[file.name] = {
					"md5" : file.md5,
					"path" : file.path,
					"size" : file.size
					}
	}
	
	var strManifest = JSON.stringify(obj); 	
	fs.writeFile(_outDir + "/project.manifest", strManifest, 'utf-8', function () {
		console.log("project.manifest 生成成功");
	});
}

write2manifest();

function write2versionmanifest() {
	var obj = {
		"packageUrl" : url,
		"remoteManifestUrl": url + "project.manifest",
		"remoteVersionUrl": url + "version.manifest",
		"version": version
	}
	
	var strManifest = JSON.stringify(obj); 	
	fs.writeFile(_outDir + "/version.manifest", strManifest, 'utf-8', function () {
		console.log("version.manifest 生成成功");
	});
}

write2versionmanifest();
 


