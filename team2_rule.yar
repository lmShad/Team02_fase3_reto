rule team02_fcfm_edu_malware {
    meta:
        description = "Detecta el binario educativo team02_sample.exe del Equipo 2"
        author = "Equipo 2 - FCFM"
        date = "13/04/2026"
        malware_type = "benign_simulator"
        hash_reference = "Calcular con certutil -hashfile team02_sample.exe SHA256"

 

    strings:
        $magic = "MAGIC: fcfm-team2-pac" ascii wide
        $msg_inicio = "Iniciando el malware simulado del equipo..." ascii wide
        $msg_espera = "Esperamos 2 segundos..." ascii wide
        $temp_path = "C:\\temp\\log_fcfm.txt" ascii wide
        $payload = "Payload de prueba:" ascii
        $calc = "calc.exe" ascii

 

        $api_sleep = "Sleep" ascii
        $api_createfile = "CreateFileA" ascii
        $api_writefile = "WriteFile" ascii
        $api_winexec = "WinExec" ascii

 

    condition:
        uint16(0) == 0x5A4D and 
        $magic and (
            (#api_sleep + #api_createfile + #api_writefile + #api_winexec >= 2) or
            $temp_path
        )
}
