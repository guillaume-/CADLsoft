import processing.net.*;

class Serveur{ 
    class Data{
        boolean mlampe = false,
                mvolet = false,
                mradiateur = false,
                presence = false;
        int thermostat = 15;
        int Timer = 0;
        int HG = 0;
        int HD = 0;
        int BG = 0;
        int BD = 0;
        float temp = 15;
    }

    String HTTP_GET_REQUEST = "GET /",
           HTTP_HEADER = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n",
           HTTP_ERROR = "HTTP/1.1 404 FILE_NOT_FOUND\r\n",
           HTML_AUTOR = "<html><head><meta http-equiv='refresh' content='1' />"
                        +"<style> h3{font-family: \"Lucida Grande\","
                        +" Tahoma, Verdana, sans-serif;color: rgba(0, 0, 0, 0.6);font-size: 32px;"
                        +"font-weight: normal;text-align: center;text-shadow: none;}</style>"
                        +"</head><body><h3>",
           HTML_AUTORE = "</h3></body></html>";
  
    Client c;
    Data data = new Data();
    Server s;
    String input;
    String[] args;
    String[] request;
    byte[] page ;

    Serveur(PApplet instance){
        s = new Server(instance, 8080);
    }

    void start() {
        thread("runserveur");
    }

    public void serveur(){
        int index;
        while(true){
            c = s.available();
            delay(20);
            if(c != null){
                input = c.readString();
                index = input.indexOf("\n");
                if(index != -1)
                    input = input.substring(0, index);
                if(input.indexOf(HTTP_GET_REQUEST) == 0){
                    request = splitTokens(input," ?");
                    print("request : "+request[1]+"\r\n");
                    if(request[1].equals("/"))
                        request[1]="/index.html";
                    envoyerrecevoir();
                }
            }
        }
    }

    void traitement(String input){
        args = splitTokens(input," &?=");
            if(args.length >= 11)
                for(int i =2 ;i<args.length-1;i+=2){
                    switch(args[i]){
                        case "lumiere" :
                            data.mlampe = args[i+1].equals("false");
                            break;
                        case "volets":
                            data.mvolet = args[i+1].equals("false");
                            break;
                        case "radiateurs":
                            data.mradiateur = args[i+1].equals("false");
                            break;
                        case "Thermostat":
                            data.thermostat = int(args[i+1]);
                            break;
                        case "presence":
                            data.presence=args[i+1].equals("true");
                    }
                }
    }

    void envoyervar(int nb){
        c.write(HTML_AUTOR);
        c.write(""+nb);
        c.write(HTML_AUTORE);
    }

    void envoyerrecevoir(){
        try{
            page = null;
            c.write(HTTP_HEADER);
            switch(request[1]){
                case "/HD":
                    envoyervar(data.HD);
                    break;
                case "/HG":
                    envoyervar(data.HG);
                    break;
                case "/BD":
                    envoyervar(data.BD);
                    break;
                case "/BG":
                    envoyervar(data.BG);
                    break;
                case "/pres" :
                    c.write(HTML_AUTOR);
                    if(data.Timer > 0)
                        c.write("OUI");
                    else
                        c.write("NON");
                    c.write(HTML_AUTORE);
                    break;
                case "/temp":
                    c.write(HTML_AUTOR);
                    c.write(""+nf(data.temp,2,1)+"C");
                    c.write(HTML_AUTORE);
                    break;
                default:
                    page = loadBytes("."+request[1]);
                    c.write(page);
            }
            c.write("\r\n\r\n");
            c.stop();
            delay(1);
            while(c.available() < 0)
                input = c.readString();
            traitement(input);
        }catch(Exception e){
            c.write(HTTP_ERROR);
            c.write("\r\n\r\n");
        }
    }
}