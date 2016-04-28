class Lampe{
    int x;
    int y;

    Lampe(int x, int y){
        this.x = x;
        this.y = y;
    }

    void update(int HG, int HD, int BG, int BD, int Timer, boolean manuel){
        noStroke();
        int Q11 = 10-BG;
        int Q12 = 10-HG;
        int Q21 = 10-BD;
        int Q22 = 10-HD;
        int x1 = 80;
        int x2 = w-80;
        int y1 = h-120;
        int y2 = 120;
        float l = 0;
        // interpolation bilinéaire
        if(Timer >= 0 && !manuel){
            l = (1.0/((x2-x1)*(y2-y1)))*(Q11*(x2-this.x)*(y2-this.y)+Q21*(this.x-x1)*(y2-y)+Q12*(x2-this.x)*(this.y-y1)+Q22*(this.x-x1)*(this.y-y1));
        }
        fill(color(l/10*255, l/10*255, 0));
        ellipse(x, y, 40, 40);
    }
}