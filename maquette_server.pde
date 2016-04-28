import controlP5.*;
ControlP5 control;
int w = 800;
int h = 600;
int HG = 0;
int HD = 0;
int BG = 0;
int BD = 0;
int Timer = 0;
float temp = 15;
float thermostat= 15;
Textlabel thermometre;
boolean radiateur = false,
        vmanuel = false, // volets mode manuel
        lmanuel = false, // lumières mode manuel
        rmanuel = false; // radiateurs mode manuel
Lampe[] lampes = new Lampe[8];
Volet[] volet = new Volet[2];
PImage img;
Serveur serveur;

void setup(){
    size(800, 600);
    background(255);
    img = loadImage("logo.png");
    GUI();
    initLampe();
    volet[0] = new Volet(w/4-100, 60);
    volet[1] = new Volet(w/4*3-100, 60);
    serveur = new Serveur(this);
    serveur.start();
}

void draw(){
    Timer--;
    fill(255);
    rect(0, 0, w, h);
    stroke(0);
    strokeWeight(2);
    fill(color(((temp-15)*255/30), 100,255-((temp-15)*255/30)));
    thermometre.setText(""+nf(temp, 2, 2)+"ºC");
    rect(20, 60, w-40, h-120);
    image(img, w/2-150, h/2-50, 300, 100);
    updatevalue();
    presence();
    rad();
    for(int i = 0; i<8; i++)
        lampes[i].update(HG, HD, BG, BD, Timer, lmanuel); 
    volet[0].update(Timer, vmanuel);
    volet[1].update(Timer, vmanuel);
}

void GUI(){
    control = new ControlP5(this);
    control.addSlider("HG", 0, 10, 0, 20, 10, 100, 20);
    control.addSlider("HD", 0, 10, 0, w-120, 10, 100, 20);
    control.addSlider("BG", 0, 10, 0, 20, h-40, 100, 20);
    control.addSlider("BD", 0, 10, 0, w-120, h-40, 100, 20);
    thermometre = control.addTextlabel("Thermometre").setPosition(20, 88).setText("temp");
}

void rad(){
    fill(color(100, 100, 100));
    rect(20, 60, 48, h-120);
    if(radiateur){
      fill(color(255, 100, 100)); 
      temp += 0.01;
      if(temp > thermostat+0.5)
          radiateur = false;
    }else{
      fill(0);
      temp -= 0.0025;
      if(temp < thermostat-0.5)
          radiateur = !rmanuel;
    }
    ellipse(30, 70, 16, 16);  
}

void initLampe(){
    lampes[0] = new Lampe(80, 120);
    lampes[1] = new Lampe(80, h-120);
    lampes[2] = new Lampe(w-80, 120);
    lampes[3] = new Lampe(w-80, h-120);
    lampes[4] = new Lampe((w)/2, 120);
    lampes[5] = new Lampe((w)/2, (h-120));
    lampes[6] = new Lampe((w)/4, h/2);
    lampes[7] = new Lampe(((w)/4)*3, h/2);
}

void presence(){
    if(serveur.data.presence){
        Timer = 50;
        fill(color(20, 150, 20));
        ellipse(w/2, h/2, 32, 32);
    }
}

void runserveur(){
    while(true)
        serveur.serveur();
}

void updatevalue(){
    lmanuel = serveur.data.mlampe;
    vmanuel = serveur.data.mvolet;
    rmanuel = serveur.data.mradiateur;
    thermostat = serveur.data.thermostat;
    serveur.data.HG = HG;
    serveur.data.HD = HD;
    serveur.data.BG = BG;
    serveur.data.BD = BD;
    serveur.data.Timer = Timer;
    serveur.data.temp = temp;
}