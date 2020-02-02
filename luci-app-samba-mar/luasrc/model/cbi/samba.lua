-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2008 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

local fs = require "nixio.fs"

local smbd =(luci.sys.call("pidof smbd > /dev/null") == 0)
local nmbd =(luci.sys.call("pidof nmbd > /dev/null") == 0)
if smbd and nmbd then	
	m = Map("samba", translate("Network Shares"), "<b><font color=\"green\">" .. translate("Samba is running") .. "</font></b>")
else
	m = Map("samba", translate("Network Shares"), "<b><font color=\"red\">" .. translate("Samba is not running") .. "</font></b>")
end

if not nixio.fs.access("/usr/sbin/samba_multicall") then
downloadfile=1		
end

s = m:section(TypedSection, "samba", "Samba", translate("<p>如需帮助:<a target=\"_blank\" href=\"http://myop.cf/archives/category/firmware-guide/\">请查看使用教程</a></p>"))
s.anonymous = true

s:tab("general",  translate("General Settings"))
s:tab("template", translate("Edit Template"))

enable = s:taboption("general", Flag, "enabled", translate("Enable"), translate("Enable Samba"))
enable.rmempty = false
enable.optional = false

function enable.write(self, section, value)
	if value == "0" then
		os.execute("/etc/init.d/samba disable")
		os.execute("/etc/init.d/samba stop")
	else
		os.execute("/etc/init.d/samba enable")
	end
	Flag.write(self, section, value)
end


if downloadfile==1 then
dl_mod = s:taboption("general", Value, "dl_mod", translate("下载方式选择"), translate("选择下载执行文件的方法，从git可下载到最新版本，从博客只能下载到不定期更新的固定的版本，也可以使用自定义下载方式。"))
dl_mod:value("git", "官方下载")
dl_mod:value("blog", "博客下载")
dl_mod:value("custom", "自定义下载")

dl_mod.default = "git"
dl_mod.optional = true
dl_mod.rmempty = true

e = s:taboption("general", Value, "version_g","下载执行文件版本")
e:value("ar71xx", "ar71xx")
e:value("mt7620", "mt7620")
e:value("mt7621", "mt7621")
e:value("mt7628", "mt7628")
e:value("rt288x", "rt288x")
e:value("rt305x", "rt305x")
e:value("rt3883", "rt3883")
e.default = "ar71xx"
e:depends("dl_mod", "git")

e = s:taboption("general", Value, "version_d","下载执行文件版本")
e:value("ar71xx", "ar71xx")
e:value("mt7620", "mt7620")
e:value("mt7621", "mt7621")
e:value("mt7628", "mt7628")
e.default = "ar71xx"
e:depends("dl_mod", "blog")

e = s:taboption("general", Value, "version_c","下载执行文件版本")
e:value("ar71xx", "ar71xx")
e:value("mt7620", "mt7620")
e:value("mt7621", "mt7621")
e:value("mt7628", "mt7628")
e.default = "ar71xx"
e:depends("dl_mod", "custom")

e = s:taboption("general", Value, "c_url", "自定义执行文件下载网址", "网址中以http或者https开始，不能使用“/”结尾！！")
e:depends("dl_mod", "custom")
end

--[[e = s:taboption("general", Button, "del_sync", translate("del_sync"), translate("Sometims the download files is incorrect, you can delete them.<br/> <font color=\"Red\"><strong>Delete files only when multiple startup failures!!</strong></font>"))
e.inputtitle = translate("del_sync")
e.inputstyle = "apply"

function e.write(self, section)
	os.execute("/usr/bin/del_samba &")
	self.inputtitle = translate("del_sync")
end
]]--
s:taboption("general", Value, "name", translate("Hostname"))
s:taboption("general", Value, "description", translate("Description"))
s:taboption("general", Value, "workgroup", translate("Workgroup"))
s:taboption("general", Value, "homes", translate("Share home-directories"),
        translate("Allow system users to reach their home directories via " ..
                "network shares"))

e = s:taboption("general", Value, "select_config", translate("Select_config"), translate("Select config to use."))
e:value("/etc/samba/smb.conf.template", "/etc/samba/smb.conf.template")
e:value("/etc/samba/smb.conf.template2", "/etc/samba/smb.conf.template2")
e.dir = true

                
e = s:taboption("general", Value, "passwd", translate("Password"), translate("The password of root."))
e.password = true

passwd_mod = s:taboption("general", Button, "_button", translate("Passwd_mod"), translate("Change the password of root."))
passwd_mod.inputtitle = translate("Passwd_mod")
passwd_mod.inputstyle = "apply"

function passwd_mod.write(self, section)
	os.execute("sh /usr/bin/sam_passwd &")
	self.inputtitle = translate("Passwd_mod")
end


e = s:taboption("general", Value, "device", translate("Device"), translate("Select the device or directories to chmod."))
e:value("/mnt/sda*", "/mnt/sda*")
e:value("/mnt/sdb*", "/mnt/sda*")
e:value("/mnt/sda1", "/mnt/sda1")
e:value("/mnt/sda2", "/mnt/sda2")
e:value("/mnt/sda3", "/mnt/sda3")
e:value("/mnt/sda4", "/mnt/sda4")
e:value("/mnt/sda5", "/mnt/sda5")
e:value("/mnt/sdb1", "/mnt/sdb1")
e:value("/mnt/sdb2", "/mnt/sdb2")
e:value("/mnt/sdb3", "/mnt/sdb3")
e:value("/mnt/sdb4", "/mnt/sdb4")
e:value("/mnt/sdb5", "/mnt/sdb5")
e.optional = false
e.rmempty = true

e = s:taboption("general", Value, "chmod_mask", translate("Mask"), translate("Mask for new files and/or directories."))
e:value("0755", "0755")
e:value("0777", "0777")
e:value("0644", "0644")
e.optional = false
e.rmempty = true

e = s:taboption("general", ListValue, "chmod_files", translate("Chmod_files"), translate("While true,chmod files,else only chmod directories."))
e:value("false", translate("false"))
e:value("true",  translate("true"))
e.optional = false
e.rmempty = true


chmod_dir = s:taboption("general", Button, "_button", translate("Chmod_dir"), translate("Chmod the files that yor select."))
chmod_dir.inputtitle = translate("Chmod_dir")
chmod_dir.inputstyle = "apply"

function chmod_dir.write(self, section)
	os.execute("sh /usr/bin/chmod_dir.sh &")
	self.inputtitle = translate("Chmod_dir")
end


tmpl = s:taboption("template", Value, "_tmpl",
	translate("Edit the 1st template that is used for generating the samba configuration."), 
	translate("This is the content of the file '/etc/samba/smb.conf.template' from which your samba configuration will be generated. " ..
		"Values enclosed by pipe symbols ('|') should not be changed. They get their values from the 'General Settings' tab."))

tmpl.template = "cbi/tvalue"
tmpl.rows = 20

function tmpl.cfgvalue(self, section)
	return nixio.fs.readfile("/etc/samba/smb.conf.template")
end

function tmpl.write(self, section, value)
	value = value:gsub("\r\n?", "\n")
	nixio.fs.writefile("//etc/samba/smb.conf.template", value)
end

tmpl2 = s:taboption("template", Value, "_tmpl2",
	translate("Edit the 2nd template that is used for generating the samba configuration."), 
	translate("This is the content of the file '/etc/samba/smb.conf.template' from which your samba configuration will be generated. " ..
		"Values enclosed by pipe symbols ('|') should not be changed. They get their values from the 'General Settings' tab."))

tmpl2.template = "cbi/tvalue"
tmpl2.rows = 20

function tmpl2.cfgvalue(self, section)
	return nixio.fs.readfile("/etc/samba/smb.conf.template2")
end

function tmpl2.write(self, section, value)
	value = value:gsub("\r\n?", "\n")
	nixio.fs.writefile("//etc/samba/smb.conf.template2", value)
end


s = m:section(TypedSection, "sambashare", translate("Shared Directories"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"

s:option(Value, "name", translate("Name"))
pth = s:option(Value, "path", translate("Path"))
if nixio.fs.access("/etc/config/fstab") then
        pth.titleref = luci.dispatcher.build_url("admin", "system", "fstab")
end

s:option(Value, "users", translate("Allowed users")).rmempty = true

ro = s:option(Flag, "read_only", translate("Read-only"))
ro.rmempty = false
ro.enabled = "yes"
ro.disabled = "no"

go = s:option(Flag, "guest_ok", translate("Allow guests"))
go.rmempty = false
go.enabled = "yes"
go.disabled = "no"

cm = s:option(Value, "create_mask", translate("Create mask"),
        translate("Mask for new files"))
cm.rmempty = true
cm.size = 4

dm = s:option(Value, "dir_mask", translate("Directory mask"),
        translate("Mask for new directories"))
dm.rmempty = true
dm.size = 4


return m
