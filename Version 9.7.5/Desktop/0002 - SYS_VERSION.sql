UPDATE SYS_VERSION SET	VER_ACTUAL_WARP='9.75',
						VER_MIN_COMPATIBLE='9.75',
						FECHA_INSTALACION=GETDATE()
WHERE NOM_DLL<>'WARP.EXE'						

UPDATE SYS_VERSION SET	VER_ACTUAL_WARP='9.75',
						VER_MIN_COMPATIBLE='9.75',
						FECHA_INSTALACION=GETDATE(),
						OBS_ACTUALIZACION='Debe actualizar la versi�n actual a la version 9.7.5. Por favor, comuniquese con el departamento de sistemas.'
WHERE NOM_DLL='WARP.EXE'
