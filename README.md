# Geocompass

### What is it?
Geocompass is an add-on for FFXI's third-party loader and hook Ashita (https://www.ashitaxi.com/) customized for CatsEye implementation of GEO's trait Cardinal Chant (https://www.bg-wiki.com/ffxi/CatsEyeXI_Systems/Jobs#Adjustments_5).
The purpose of this add-on is to provide clear tracking of the elemental bonus given by the trait, based on the character orientation.
<br></br>  
### What is not?
This add-on is <b>NOT</b> a compass that can be used for the original Cardinal Chant implementation (https://www.bg-wiki.com/ffxi/Cardinal_Chant).
I will consider working on this depending on the volume of demand for it.
<br></br>
### How does it work?
It displays a compass pointing at the element for which the character is benefitting from a buff.
<br></br>
<p align="center">
<img src="https://github.com/ariel-logos/ElfyLab/blob/master/img/gecompassdemo-noaudio-optimized.gif" alt="Geocompass in action"></img>
</p>

### Main features
<ul>
  <li>Animated visuals for improved clarity.</li>
  <li>Can be set to autohide when GEO is not the main job, when the target is not locked and when the target is not a mob.</li>
  <li>Resizable compass.</li>
  <li>Can hide different parts to achieve a minimalistic look.</li>
  <li>Autosaves settings.</li>
</ul>

### Installation
Go over the <a href="https://github.com/ariel-logos/Geocompass/releases" target="_blank">Releases</a> page, download the latest version and unpack it in the add-on folder in your Ashita installation folder. You should now have among the other add-on folders the "geocompass" one!
<br></br>
### Compatibility Issues
Currently non compatible with the original implementation of Cardinal Chant (https://www.bg-wiki.com/ffxi/Cardinal_Chant).
<br></br>
### Functionalities

#### Commands
```/addon load geocompass``` Loads the add-on in Ashita.

```/addon unload geocompass``` Unloads the add-on from Ashita.

```/gecompass settings``` Shows/hides the config UI.
<br></br>
#### Settings Window
In this window you can adjust several add-on settings, in particular:
<ol>
  <li><b>Compass scale:</b> sets the size of the compass.</li>
  <li><b>Disable bell icon:</b> hides the bell icon.</li>
  <li><b>Disable compass needle:</b> hides the compass needle rotating in the center.</li>
  <li><b>Disable central token:</b> hides the decorative token on top of the needle.</li>
  <li><b>Enable only on GEO job:</b> when enabled, the Geocompass won't activate while the main job isn't set to GEO.</li>
  <li><b>Show only when target is locked on:</b> the compass will autohide when there's no locked on target.</li>
  <li><b>Only apply on mobs:</b> modifies the previous behavior (show on locked on targets) to only show the compass on locked on mobs.</li>
</ol>


<p align="center">
<a href="https://github.com/ariel-logos/Geocompass/assets/78350872/f3aaecf8-54db-4e5a-9b9f-1dbf183f566c"><img src="https://github.com/ariel-logos/Geocompass/assets/78350872/f3aaecf8-54db-4e5a-9b9f-1dbf183f566c" alt="Geocompass Settings"/></a>
</p>

