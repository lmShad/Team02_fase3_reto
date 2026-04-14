1. Análisis de Funciones y Desensamblado
Para iniciar el proceso de patching, se realizaron las tareas de reconocimiento del binario utilizando comandos de Radare2:

Comando aaa: Ejecutado para realizar un análisis de intensidad completa (Analyze all), permitiendo la identificación de símbolos, funciones y referencias del programa.


<img width="780" height="139" alt="Imagen1" src="https://github.com/user-attachments/assets/d4a7ad2e-38a3-47e2-8bad-0dc0bba034fc" />


Comando afl: Se listaron las funciones detectadas. Se identificó el punto de entrada principal en 0x140001020 y se localizó la función sym.main como el objetivo del análisis lógico.

<img width="596" height="195" alt="Imagen2" src="https://github.com/user-attachments/assets/e346d1b1-5996-4cf4-9d4c-9bbc55e8f79d" />


Comando pdf: Se generó el desensamblado de la función principal. A través de la salida de este comando, se examinaron las instrucciones en lenguaje ensamblador para rastrear el flujo de control del programa.

<img width="595" height="167" alt="Imagen3" src="https://github.com/user-attachments/assets/5f64b859-5753-4b40-8ca5-8c59b884ffd7" />


2. Localización de la Instrucción Condicional
Tras analizar el flujo de la función principal, se identificó un punto crítico donde el programa decide su comportamiento basándose en el resultado de una operación previa (CreateFileA):

Dirección: 0x140001591.

Instrucción Original: je 0x1400015e3 (Jump if Equal).

Propósito: Esta condicional provocaba que el programa saltara a una rutina de error si la comparación en 0x14000158c resultaba verdadera.



<img width="780" height="396" alt="Imagen4" src="https://github.com/user-attachments/assets/7e79e0c8-3be1-4f34-900c-ec1624a5d5db" />





3. Modificación del Binario (Patching en Cutter)
Utilizando la interfaz de Cutter, se procedió a realizar el parcheo para alterar el flujo de ejecución:

Cambio realizado: Se invirtió la condicional de je a jne (Jump if Not Equal) en la dirección 0x140001591.

<img width="411" height="213" alt="Imagen5" src="https://github.com/user-attachments/assets/5783f020-7a44-45c3-a20a-dfd2e0e2f767" />


Opcodes: La secuencia de bytes cambió de 74 50 a 75 50.

<img width="432" height="220" alt="Imagen6" src="https://github.com/user-attachments/assets/d5971294-ff00-45fd-b0c7-e40222db032f" />



<img width="512" height="107" alt="Imagen7" src="https://github.com/user-attachments/assets/bdaaa708-37e9-4f26-a2b5-8036e6aed42a" />

Integridad: Se seleccionó la opción "Rellenar el resto de los bytes con códigos de operación NOP" para asegurar que la modificación no corrompiera el resto del código.




4. Comparación de Comportamiento (Original vs. Parcheado)
El parcheo permitió evadir la restricción lógica original del malware simulado:

Comportamiento Original: El programa detectaba una falla en la creación del archivo temporal y se detenía.

Comportamiento Parcheado: Al invertir la lógica, el programa ahora evade el bloqueo, continúa su ejecución y procede a realizar acciones adicionales, como el lanzamiento de procesos externos (lanzando calc.exe).

<img width="713" height="402" alt="Imagen8" src="https://github.com/user-attachments/assets/032860d2-e33b-4189-92be-b2c8a3c79c57" />

