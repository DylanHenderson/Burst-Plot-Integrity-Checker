package plotintegritychecker;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import plotintegritychecker.cryptohash.MiningPlot;
import org.apache.commons.codec.binary.Hex;
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


/**
 *
 * @author Dylan
 */
public class PlotIntegrityChecker {

    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        
         String file = "D:\\plots5o\\18189969833915929775_118947845_10240000_10240000";
         PlotInfo plotInfo = new PlotInfo("18189969833915929775_118947845_10240000_10240000");
         System.out.println(Long.toUnsignedString(plotInfo.getAccountID()));
       
         try {
             byte[] b = new byte[64];
             byte[] b2 = new byte[64];
             InputStream is = new FileInputStream(file);
             int readBytes = 0;
             int readBytesLast = 0;
             
             boolean found = true;

             //Create a MiningPlot for the scoop in each nonce (the mining plot is unoptomised so here we think scoops in nonces!)
             MiningPlot mp = new MiningPlot(plotInfo.getAccountID(),plotInfo.getNonceStart());
             MiningPlot mpLast = new MiningPlot(plotInfo.getAccountID(),plotInfo.getNonceStart()+plotInfo.getNonceCount()-1);
             int corruptionCount = 0;
             
             // Optimised files flip the paradigm. Now we have nonces inside scoops.
             // Each scoop has x many nonces, where x is indicated on file
             // The odd thing is that we used to think of a nonce as a colection of scoops, now this is not the case.
             // A scoop is now a collection of nonces.
             // Optimised plot file
             for (int scoop = 0; scoop < 4096; scoop++) {
                 
                 
                 // Read in the first nonce 
                 readBytes = is.read(b);
                 if (readBytes == -1) {
                     break;
                 }
                 // skip all the nonces (inside the scoop)
                 is.skip((plotInfo.getNonceCount()*64)-128);
                 
                 readBytes = is.read(b2);
                 if (readBytes == -1) {
                     break;
                 }
                 
                 String hexScoop = Hex.encodeHexString(mp.getScoop(scoop));
                 String hexScoopLast = Hex.encodeHexString(mpLast.getScoop(scoop));                
                 System.out.println("calculated: "+hexScoopLast);
                 System.out.println(Hex.encodeHexString(b2));
                 
                 // compare the first nonce to what we calculated should be there
                 if (!hexScoop.equals(Hex.encodeHexString(b)) || !hexScoopLast.equals(Hex.encodeHexString(b2))) {
                     found = false;
                     corruptionCount++;
                 }
             }
             
             if (found != true) {
                 System.out.println("corruption found in: "+ corruptionCount + "out of 8000 scoops checked");
             }

         } catch (IOException ioe) {
             System.out.println("Error "+ioe.getMessage());
         }
         
         
         for (int i = 0; i < plotInfo.getNonceCount(); i++) {
             
             
         }
         
         
    }
}
