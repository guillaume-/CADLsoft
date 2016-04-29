import controlP5.*;
ControlP5 control;
final int LARGEUR_MAQUETTE = 800,
          HAUTEUR_MAQUETTE = 600;

Lampe[] lampes = new Lampe[8];
Volet[] volet = new Volet[2];
Thermostat thermostat = new Thermostat();
int[] infos = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
/* Infos :
16 entrees sorties gérées par un Raspberry
[0] void, [1..8] Lampes, [12..13] Thermostats 
*/

float temperature = 15; // temperature reelle
PImage img; // pour l'écran - inactif
int HG = 0, // Capteurs Haut Gauche,
    HD = 0, //          Haut Droit,
    BG = 0, //          Bas Gauche,
    BD = 0, //          Bas Droit
    Timer = 0;
boolean mode_manuel_Lampes = false,
        mode_manuel_Volets = false,
        mode_manuel_Thermostat = false;

Serveur serveur;

// Initialisation des lampes
void initLampe(){
    lampes[0] = new Lampe(80, 120);
    lampes[1] = new Lampe(80, HAUTEUR_MAQUETTE-120);
    lampes[2] = new Lampe(LARGEUR_MAQUETTE-80, 120);
    lampes[3] = new Lampe(LARGEUR_MAQUETTE-80, HAUTEUR_MAQUETTE-120);
    lampes[4] = new Lampe((LARGEUR_MAQUETTE)/2, 120);
    lampes[5] = new Lampe((LARGEUR_MAQUETTE)/2, (HAUTEUR_MAQUETTE-120));
    lampes[6] = new Lampe((LARGEUR_MAQUETTE)/4, HAUTEUR_MAQUETTE/2);
    lampes[7] = new Lampe(((LARGEUR_MAQUETTE)/4)*3, HAUTEUR_MAQUETTE/2);
}

// Initialisation générale
void setup(){
    size(800, 600);
    background(255);
    img = loadImage("logo.png");
    GUI();
    initLampe();
    volet[0] = new Volet(LARGEUR_MAQUETTE/4-100, 60);
    volet[1] = new Volet(LARGEUR_MAQUETTE/4*3-100, 60);
    serveur = new Serveur(this);
    serveur.start();
}

// Gestion du thermostat
void rad(){
    fill(color(100, 100, 100));
    rect(20, 60, 48, HAUTEUR_MAQUETTE-120);
    if(thermostat.etat){
        infos[12] = 100;
        infos[13] = 100;
        fill(color(255, 100, 100)); 
        temperature += 0.01;
        if(temperature > thermostat.temperature_cible+0.5 || mode_manuel_Thermostat)
            thermostat.etat = false;
    }else{
        infos[12] = 0;
        infos[13] = 0;
        fill(0);
        temperature -= 0.0025;
        if(temperature < thermostat.temperature_cible-0.5)
            thermostat.etat = !mode_manuel_Thermostat;
    }
    ellipse(30, 70, 16, 16);  
}

void draw(){
    Timer--;
    fill(255);
    rect(0, 0, LARGEUR_MAQUETTE, HAUTEUR_MAQUETTE);
    stroke(0);
    strokeWeight(2);
    fill(color(((temperature-15)*255/30), 100, 255-((temperature-15)*255/30)));
    rect(20, 60, LARGEUR_MAQUETTE-40, HAUTEUR_MAQUETTE-120);
    image(img, LARGEUR_MAQUETTE/2-150, HAUTEUR_MAQUETTE/2-50, 300, 100);
    updatevalue();
    presence();
    rad();
    for(int i = 0; i<8; i++){
        lampes[i].update(HG, HD, BG, BD, Timer, mode_manuel_Lampes);
        infos[i+1]= int(lampes[i].luminance*10);
    }
    volet[0].update(Timer, mode_manuel_Volets);
    volet[1].update(Timer, mode_manuel_Volets);
    if (frameCount%5 ==0) {
        String[] args = new String[18];
        args[0] = "/usr/bin/python";
        args[1] = "/home/pi/nanocampus/maquette_server/data/i2ccontrol/nanocampuscontroller.py";
        for(int i = 2; i < 18; i++)
            args[i] = str(infos[i-2]);
        try{
            Runtime.getRuntime().exec(args);
        }catch(Exception E){}
    }
}

// Interface graphique
void GUI(){
    control = new ControlP5(this);
    control.addSlider("HG", 0, 10, 0, 20, 10, 100, 20);
    control.addSlider("HD", 0, 10, 0, LARGEUR_MAQUETTE-120, 10, 100, 20);
    control.addSlider("BG", 0, 10, 0, 20, HAUTEUR_MAQUETTE-40, 100, 20);
    control.addSlider("BD", 0, 10, 0, LARGEUR_MAQUETTE-120, HAUTEUR_MAQUETTE-40, 100, 20);
}

void presence(){
    if(serveur.data.presence){
        Timer = 50;
        fill(color(20, 150, 20));
        ellipse(LARGEUR_MAQUETTE/2, HAUTEUR_MAQUETTE/2, 32, 32);
    }
}

void runserveur(){
    while(true)
        serveur.serveur();
}

void updatevalue(){
    mode_manuel_Lampes = serveur.data.mlampe;
    mode_manuel_Volets = serveur.data.mvolet;
    mode_manuel_Thermostat = serveur.data.mradiateur;
    thermostat.temperature_cible = serveur.data.thermostat;
    serveur.data.HG = HG;
    serveur.data.HD = HD;
    serveur.data.BG = BG;
    serveur.data.BD = BD;
    serveur.data.Timer = Timer;
    serveur.data.temp = temperature;
}