#
# Module manifest for module 'SSMDemoModule'
#

@{
	ModuleVersion = '1.0'
	GUID = '02370c4b-147c-4d0a-9591-4e82cd641cc5'
	Author = 'Siva Padisetty'
    NestedModules="SSMDemoModule.psm1", "fio.psm1"
    FunctionsToExport="OSSetup", "ChefInstall", "Test1", "Test2", "FIOTest"
}

