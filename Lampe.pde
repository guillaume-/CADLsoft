class Lampe{
    int x;
    int y;
    float luminance = 0;

    Lampe(int x, int y){
        this.x = x;
        this.y = y;
    }

    void display(float luminance){
        float color_luminance = luminance/10*255; 
        fill(color(color_luminance, color_luminance, 0));
        ellipse(x, y, 40, 40);
    }

    void update(int HG, int HD, int BG, int BD, int Timer, boolean manuel){
        noStroke();
        final int x1 = 80, // position des 4 angles
                  x2 = LARGEUR_MAQUETTE-80,
                  y1 = HAUTEUR_MAQUETTE-120,
                  y2 = 120;
        int Q11 = 10-BG, // Q11..Q22 points de l'interpollation bilinéaire
            Q12 = 10-HG,
            Q21 = 10-BD,
            Q22 = 10-HD;
        float luminance = 0;
        if(Timer >= 0 && !manuel){ // interpolation bilinéaire
            luminance = (1.0/((x2-x1)*(y2-y1)))*(Q11*(x2-this.x)*(y2-this.y)+Q21*(this.x-x1)*(y2-y)+Q12*(x2-this.x)*(this.y-y1)+Q22*(this.x-x1)*(this.y-y1));
        }
        this.luminance = luminance;
        display(luminance);
    }
}