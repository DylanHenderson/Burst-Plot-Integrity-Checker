/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package plotintegritychecker;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * Class containing all info required from a plot file name
 */
public class PlotInfo {

    private Long accountID;
    private Long nonceStart;
    private Long nonceCount;
    private Long staggerSize;
    String FILEPATTERN = "(\\d*)_(\\d*)_(\\d*)_(\\d*)$";
    Pattern fileRegex;

    public PlotInfo(String fileName) {
        fileRegex = Pattern.compile(FILEPATTERN);
        generatePlotInfoFromFileName(fileName);
    }

    // Generates unsigned long values for required fields form the file name
    private void generatePlotInfoFromFileName(String fileName) {
        Matcher m = fileRegex.matcher(fileName);
        if (m.find() && m.groupCount() == 4) {
            accountID = Long.parseUnsignedLong(m.group(1));
            nonceStart = Long.parseLong(m.group(2));
            nonceCount = Long.parseLong(m.group(3));
            staggerSize = Long.parseLong(m.group(4));
        } else {
            System.out.println("not all values found when pattern matching");
        }
    }

    /**
     * @return the accountID
     */
    public Long getAccountID() {
        return accountID;
    }

    /**
     * @return the nonceStart
     */
    public Long getNonceStart() {
        return nonceStart;
    }

    /**
     * @return the nonceCount
     */
    public Long getNonceCount() {
        return nonceCount;
    }

    /**
     * @return the stagerSize
     */
    public Long getStagerSize() {
        return staggerSize;
    }
}
