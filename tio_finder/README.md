# 🪵 Tió Finder

Una aplicació Flutter per buscar i trobar "tions" (troncs de nadal catalans) utilitzant un radar estil Dragon Ball Z.

## ✨ Característiques

### 🎯 Sistema de Radar
- Radar en temps real amb animació de sweep
- 5 nivells de zoom diferents (x1, x1.5, x2, x4, x6)
- Indicador visual quan estàs molt a prop d'un tió
- Efectes de pulsació per objectius propers
- Feedback hàptic basat en la proximitat

### 🪵 Gestió de Tions
- Amaga tions a la teva ubicació actual
- Amaga tions en qualsevol punt del mapa
- Visualitza tots els teus tions guardats
- Sistema de fake tions per fer més interessant la cerca
- Zones configurables per generar fake tions

### 📊 Estadístiques i Progrés
- Comptador total de tions trobats
- Distància total recorreguda
- Temps rècord de trobada
- Missatges motivacionals segons el teu progrés

### 🏅 Sistema d'Assoliments
- 12 assoliments diferents per desbloquejar
- Assoliments de tions trobats (1, 5, 10, 25, 50)
- Assoliments de distància recorreguda (1km, 5km, 10km, 42km)
- Assoliments de velocitat (trobar en menys de 5min, 2min, 1min)
- Barres de progrés per cada assoliment

### ⚙️ Configuració i Ajuda
- Pantalla de configuració completa
- Tutorial i ajuda detallada
- Opció per reiniciar configuració
- Opció per esborrar totes les dades
- Menú secret per accedir a funcions avançades

## 🎮 Com Jugar

1. **Amagar un Tió**: Toca 10 vegades el títol "TIÓ FINDER" per accedir al menú secret
2. **Usar el Radar**: Obre el radar des del menú principal i camina cap als objectius verds
3. **Trobar Tions**: Quan estiguis a menys de 5 metres, prem el botó "TIÓ TROBAT"
4. **Desbloquejar Assoliments**: Continua jugant per desbloquejar tots els assoliments

## 🎨 Tipus de Pistes

- 🟢 **Verds**: Tions reals (els objectius principals)
- 🟡 **Grocs**: Fake tions persistents (es mantenen al radar)
- 🔴 **Vermells**: Fake tions que desapareixen quan t'hi acostes

## 🛠️ Tecnologies

- Flutter 3.4.0+
- Geolocator per GPS
- Flutter Compass per orientació
- SharedPreferences per desar dades
- Vibration per feedback hàptic
- Flutter Map per selecció de mapa
- Provider per gestió d'estat

## 📱 Instal·lació

```bash
flutter pub get
flutter run
```

## 🎯 Consells Professionals

- Utilitza zoom alt (x4-x6) quan estiguis molt a prop d'un objectiu
- Gira't lentament per ubicar millor els objectius al radar
- Les pistes vermelles desapareixen quan t'hi acostes, així que no perdis temps perseguint-les
- Configura zones de fake tions per fer més interessant la cerca
- El dispositiu vibrarà més fort com més proper estiguis a un tió real

## 📄 Llicència

Aquest projecte està sota llicència MIT.
