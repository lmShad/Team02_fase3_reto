# Resumen de Detección - Equipo 2

**Binario:** `team02_sample.exe`
**Fecha de análisis:** 13 de abril de 2026
**Arquitectura:** amd64 (64 bits)
**SHA256:** `03983e66c1570b51ee197d0a3a05ee258fd28a1504a9b10116409168c525cd87`

---

## 1. Detección con YARA

### Regla utilizada: `team2_rule.yar`

### Resultado del escaneo:
**MATCH:** El binario es detectado por la regla YARA

### Indicadores que activaron la regla:

| Indicador | Presente |
|-----------|----------|
| `MAGIC: fcfm-team2-pac` | Sí |
| `C:\temp\log_fcfm.txt` | Sí |
| `WinExec` | Sí |
| `CreateFileA` | Sí |
| `WriteFile` | Sí |
| `Sleep` | Sí |

### Confianza de detección: **ALTA**

---

## 2. Detección con CAPA

### Comando ejecutado:
```bash
capa.exe team02_sample.exe > capa_report.txt
