# Reporte de Análisis Estático
**Equipo:** 2
**Binario:** `team02_sample.exe`

## 1. Cadenas encontradas (Strings)
Usando el comando `rabin2 -z team02_sample.exe`, las cadenas más relevantes que encontramos fueron:
* `Iniciando el malware simulado del equipo...`
* `MAGIC: fcfm-team2-pac`
* `Esperamos 2 segundos...`
* `C:\temp\log_fcfm.txt` (Nos dice dónde va a escribir el archivo temporal)
* `Payload de prueba:\n` (El texto que inyecta en el archivo)
* `calc.exe` (El proceso que va a ejecutar al final)

## 2. Imports (APIs de Windows)
Al revisar la IAT (Import Address Table) con `rabin2 -i`, vimos que importa `KERNEL32.dll`. Las funciones que destacan y nos dicen qué hace el programa son:
* `Sleep`: Se usa para pausar el programa (evasión).
* `CreateFileA`, `WriteFile`, `CloseHandle`: Se usan para crear y modificar el archivo en la carpeta temporal.
* `WinExec`: Es la función que manda a llamar a la calculadora.

## 3. Revisión de Secciones PE
El ejecutable tiene las secciones normales y no parece estar empacado:
* `.text`: Contiene las instrucciones y el código de nuestro `main`.
* `.rdata`: Son los datos de solo lectura (aquí están guardados los strings que sacamos en el paso 1).
* `.data`: Para las variables globales inicializadas.

## 4. Hipótesis inicial
Viendo las APIs y los strings, podemos deducir que este binario primero hace una pausa (Sleep), luego crea un archivo de texto en `C:\temp` (CreateFileA / WriteFile) y finalmente lanza un programa del sistema, que en este caso es la calculadora (WinExec).