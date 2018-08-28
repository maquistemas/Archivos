package pe.gob.sunat.controller.view;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URL;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.RadioButton;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Pane;
import javafx.stage.FileChooser;
import pe.gob.sunat.controlador.estructura.clases.Controlador;
import pe.gob.sunat.estaticos.Empaquetador;
import pe.gob.sunat.estaticos.RutasVistas;
import pe.gob.sunat.global.entidad.VariablesGlobales;
import pe.gob.sunat.logic.AppScreen;
import pe.gob.sunat.logic.RutasFormulario;
import pe.gob.sunat.logic.model.PercepcionesProperty;
import pe.gob.sunat.utilitarios.IconoMensaje;

public class CDialogC685 extends Controlador {

    @FXML
    private TextField txtRutaArchivo;
    @FXML
    private Label lblRegistCargados, lblRegistRechazados;

    @FXML
    private RadioButton rbCompPercepcion, rbCompPagoCP;
    @FXML
    private Button btnGuardarPercepciones;
    @FXML
    private HBox vbMensajePercepciones;

    @FXML
    private TableView<PercepcionesProperty> percepcionesTable;
    @FXML
    private TableColumn<PercepcionesProperty, String> filaColumn;
    @FXML
    private TableColumn<PercepcionesProperty, String> detalleColumn;

    private final ObservableList<PercepcionesProperty> percepcionesData = FXCollections.observableArrayList();

    private final List<Map> listaMap = new ArrayList<>();
    private String ruta, nombreArchivo, identificador, rucDeclarante;
    private int mesPeriodoDeclarado;
    private int anioPeriodoDeclarado;//*** jDelacruz 20170301

    private BigDecimal montoCompPercepcion = new BigDecimal("0");
    public BigDecimal montoCompPercepcionTemp = new BigDecimal("0");
    private BigDecimal montoCompPago = new BigDecimal("0");
    public BigDecimal montoCompPagoTemp = new BigDecimal("0");

    public static String CASILLA_511, CASILLA_510;///CASILLAS INTERNAS
    int can_P = 0, can_PI = 0, total_P_PI = 0, contadorTC_55 = 0;

    private String nombreArchivoP = "";
    private String nombreArchivoPI = "";
    public String nombreArchivoP_Temp = "";
    public String nombreArchivoPI_temp = "";

    private final List<Map> listaArchivoP = new ArrayList<>();
    private final List<Map> listaArchivoPI = new ArrayList<>();
    public List<Map> listaArchivoP_Temp = new ArrayList<>();
    public List<Map> listaArchivoPI_Temp = new ArrayList<>();

    private final String RUC_USUARIO = VariablesGlobales.getDatosUsuario().getRUC();

    @Override
    public void initialize(URL url, ResourceBundle rb) {
        rbCompPercepcion.setSelected(true);
        btnGuardarPercepciones.setDisable(true);
    }

    @FXML
    public void seleccionarArchivoController() {
        seleccionarArchivo();

    }

    Boolean nombreArchivoCorrecto = true;
    Boolean estructuraDeFilasCorrectas = true;

    public void seleccionarArchivo() {
        FileChooser fileChooser = new FileChooser();
        File selectedFile = fileChooser.showOpenDialog(AppScreen.FUNCIONES_GENERALES.CONS_INTEGRADOR_PRINCIPAL.getEscenario_principal());

        if (selectedFile != null) {

            nombreArchivoCorrecto = true;
            estructuraDeFilasCorrectas = true;
            //Tamaño del Nombre de Archivo P:26 PI:27
            int lengthNombreArchivo = selectedFile.getName().length();
            if (lengthNombreArchivo < 26 || lengthNombreArchivo > 27) {
                mensajeError("Error al seleccionar el archivo", "Nombre del archivo incorrecto");
//                return;
            } else {
                validarNombreArchivo(selectedFile, selectedFile.getName().substring(21));

                if (nombreArchivoCorrecto) {
                    ruta = selectedFile.getAbsolutePath();
                    txtRutaArchivo.setText(ruta);
                    nombreArchivo = selectedFile.getName();
                    identificador = nombreArchivo.substring(21);
                    rucDeclarante = nombreArchivo.substring(4, 15);
                    mesPeriodoDeclarado = Integer.parseInt(nombreArchivo.substring(19, 21));
                    anioPeriodoDeclarado = Integer.parseInt(nombreArchivo.substring(15, 19));//*** jDelaCruz 20170301

                    if (seleccionRadioCorrecta()) {

                        leerArchivo_ValidarEstructura(ruta);//VALIDAR ESTRUCTURA DE FILAS

                        if (estructuraDeFilasCorrectas) {//ESTRUCTURAS CORRECTAS
                            leerArchivo(ruta);

                            llenarTabla_DetalleErrores();
                            mostrarRegistrosCargados_Rechazados();

                            int regRechazados = Integer.parseInt(lblRegistRechazados.getText());
                            if (regRechazados < 1) {
                                btnGuardarPercepciones.setDisable(false);
                                //pintarCasilla_685();

                                if (identificador.equals("P.txt")) {
                                    nombreArchivoP_Temp = nombreArchivoP;
                                    listaArchivoP_Temp = listaArchivoP;
                                    //*** jDelacruz 05.04.2017
                                    montoCompPercepcionTemp = montoCompPercepcion;
                                    //******
                                } else if (identificador.equals("PI.txt")) {
                                    nombreArchivoPI_temp = nombreArchivoPI;
                                    listaArchivoPI_Temp = listaArchivoPI;
                                    //*** jDelacruz 05.04.2017
                                    montoCompPagoTemp = montoCompPago;
                                    //******
                                }
                                
                                llenarCasillas_511_510();
                            }
                        }

                    } else {

                        mensajeError("Error al seleccionar el archivo", "Nombre del archivo incorrecto");
//                        return;

                    }

                }
            }

        }

    }

    public boolean seleccionRadioCorrecta() {
        boolean flag = true;
        int cont = 0;
        if (rbCompPercepcion.isSelected() && identificador.equals("PI.txt")) {
            cont++;
        }
        if (rbCompPagoCP.isSelected() && identificador.equals("P.txt")) {
            cont++;
        }

        if (cont > 0) {
            flag = false;
        }

        return flag;
    }

    @FXML
    public void descargarArchivo() {

        if (lblRegistRechazados.getText().equals("0")) {
            FileChooser fileChooser = new FileChooser();
//            FileChooser.ExtensionFilter extFilter = new FileChooser.ExtensionFilter("TXT files (*.txt)", "*.txt");
//            fileChooser.getExtensionFilters().add(extFilter);

            if (listaArchivoP_Temp.size() > 0 && listaArchivoPI_Temp.size() > 0) {
                //como zip

                File fileP = new File(nombreArchivoP_Temp);
                File filePI = new File(nombreArchivoPI_temp);
                String nombreArchivoExport = nombreArchivoP_Temp.substring(0, 21) + "T";

                fileChooser.setInitialFileName(nombreArchivoExport + ".zip");
                File file = fileChooser.showSaveDialog(AppScreen.getEscenerioPrincipal());
                if (file != null) {
                    SaveFiles(listaArchivoP_Temp, listaArchivoPI_Temp, fileP, filePI, file);
                }

            } else if (rbCompPercepcion.isSelected()) {
                fileChooser.setInitialFileName(nombreArchivoP_Temp);
                File file = fileChooser.showSaveDialog(AppScreen.getEscenerioPrincipal());
                if (file != null) {
                    SaveFile(listaArchivoP_Temp, file);
                }
            } else if (rbCompPagoCP.isSelected()) {
                fileChooser.setInitialFileName(nombreArchivoPI_temp);
                File file = fileChooser.showSaveDialog(AppScreen.getEscenerioPrincipal());
                if (file != null) {
                    SaveFile(listaArchivoPI_Temp, file);
                }
            }
        }

    }

    private void SaveFile(List<Map> listaMap, File file) {
        try {
            FileWriter fileWriter = null;
            fileWriter = new FileWriter(file);
            BufferedWriter bw = new BufferedWriter(fileWriter);
            for (Map mP : listaMap) {
                bw.write(mP.get("fila").toString());
                bw.newLine();
            }
            bw.close();
        } catch (IOException ex) {
            ex.printStackTrace();
        }

    }

    private List<File> SaveFiles(List<Map> listaMapP, List<Map> listaMapPI, File fileP, File filePI, File rutaFile) {
        List<File> files = new ArrayList<>();

        try {
            FileWriter fileWriter = null;
            fileWriter = new FileWriter(fileP);
            BufferedWriter bw = new BufferedWriter(fileWriter);
            for (Map mP : listaMapP) {
                bw.write(mP.get("fila").toString());
                bw.newLine();
            }

            bw.close();
            files.add(fileP);

            FileWriter fileWriterPI = null;
            fileWriterPI = new FileWriter(filePI);
            BufferedWriter bwPI = new BufferedWriter(fileWriterPI);
            for (Map mPI : listaMapPI) {
                bwPI.write(mPI.get("fila").toString());
                bwPI.newLine();
            }

            bwPI.close();
            files.add(filePI);

            //Empaquetador.packZip(new File("D:\\00_Tutorial\\22.rar"), files);
            Empaquetador.packZip(rutaFile, files);

        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return files;
    }

    List filasError;

    public void leerArchivo_ValidarEstructura(String archivo) {
        try {

            elimnarFilasTabla();
            filaColumn.setCellValueFactory(cellData -> cellData.getValue().filaProperty());
            detalleColumn.setCellValueFactory(cellData -> cellData.getValue().detalleProperty());
            filaColumn.prefWidthProperty().bind(percepcionesTable.widthProperty().multiply(0.1));
            detalleColumn.prefWidthProperty().bind(percepcionesTable.widthProperty().multiply(1.4));
            filaColumn.setResizable(false);
            detalleColumn.setResizable(false);

            listaMap.clear();
            String cadena;
            FileReader f = new FileReader(archivo);
            BufferedReader b = new BufferedReader(f);

            int estructurasIncompletas = 0;
            int estructurasCompletas = 0;

            int filaArchivo = 1;
            filasError = new ArrayList<>();

            while ((cadena = b.readLine()) != null) {
                StringTokenizer tokens = new StringTokenizer(cadena, "|");

                if (identificador.equals("P.txt")) {
                    int NumeroCampos = 0;

                    while (tokens.hasMoreTokens()) {
                        tokens.nextToken();
                        NumeroCampos++;
                    }

                    if (NumeroCampos != 10) {
                        filasError.add(filaArchivo);
                        estructurasIncompletas++;
                    } else {
                        estructurasCompletas++;
                    }

                } else if (identificador.equals("PI.txt")) {

                    int NumeroCampos = 0;

                    while (tokens.hasMoreTokens()) {
                        tokens.nextToken();
                        NumeroCampos++;
                    }

                    if (NumeroCampos != 6) {
                        filasError.add(filaArchivo);
                        estructurasIncompletas++;
                    } else {
                        estructurasCompletas++;
                    }

                }
                filaArchivo++;
            }

            for (int i = 0; i < filasError.size(); i++) {
                String detalle = "Estructura de la fila con error";
                percepcionesData.add(new PercepcionesProperty(filasError.get(i).toString(), detalle));
            }
            percepcionesTable.setItems(percepcionesData);
            lblRegistCargados.setText(String.valueOf(estructurasCompletas));
            lblRegistRechazados.setText(String.valueOf(estructurasIncompletas));
            if (estructurasIncompletas > 0) {
                estructuraDeFilasCorrectas = false;
            }

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    public void leerArchivo(String archivo) {
        try {
            listaMap.clear();
            
            montoCompPercepcion = BigDecimal.ZERO;
            montoCompPago = BigDecimal.ZERO;
            String cadena;
            FileReader f = new FileReader(archivo);
            BufferedReader b = new BufferedReader(f);

            if (identificador.equals("P.txt")) {//GUARDA EL NOMBRE DEL ARCHIVO
                nombreArchivoP = nombreArchivo;
                listaArchivoP.clear();
            } else if (identificador.equals("PI.txt")) {//GUARDA EL NOMBRE DEL ARCHIVO
                nombreArchivoPI = nombreArchivo;
                listaArchivoPI.clear();
            }

            while ((cadena = b.readLine()) != null) {

                if (identificador.equals("P.txt")) {
                    Map filaMap = new HashMap();//GUARDAR EL ARCHIVO.TXT
                    filaMap.put("fila", cadena);
                    listaArchivoP.add(filaMap);
                } else if (identificador.equals("PI.txt")) {
                    Map filaMap = new HashMap();//GUARDAR EL ARCHIVO.TXT
                    filaMap.put("fila", cadena);
                    listaArchivoPI.add(filaMap);
                }

                StringTokenizer tokens = new StringTokenizer(cadena, "|");

                if (identificador.equals("P.txt")) {

                    while (tokens.hasMoreTokens()) {
                        Map map = new HashMap();
                        map.put("ruc", tokens.nextToken());
                        map.put("serieComprobantePercepcion", tokens.nextToken());
                        map.put("numeroComprobantePercepcion", tokens.nextToken());
                        map.put("fechEmiComprobantePercepcion", tokens.nextToken());
                        map.put("montoComprobantePercepcion", tokens.nextToken());
                        map.put("tipoComprobantePago", tokens.nextToken());
                        map.put("serieComprobantePago", tokens.nextToken());
                        map.put("numeroComprobantePago", tokens.nextToken());
                        map.put("fechEmiComprobantePago", tokens.nextToken());
                        map.put("valorTotalComprobantePago", tokens.nextToken());
                        //*** 05.04.2017
                        montoCompPercepcion = montoCompPercepcion.add(new BigDecimal(map.get("montoComprobantePercepcion").toString()));
                        //******
                        listaMap.add(map);
                    }

                } else if (identificador.equals("PI.txt")) {
                    while (tokens.hasMoreTokens()) {
                        Map map = new HashMap();
                        map.put("ruc", tokens.nextToken());
                        map.put("tipoComprobantePago", tokens.nextToken());
                        map.put("serieComprobantePago", tokens.nextToken());
                        map.put("numeroComprobantePago", tokens.nextToken());
                        map.put("fechEmiComprobantePago", tokens.nextToken());
                        map.put("montoComprobantePago", tokens.nextToken());
                        //*** 05.04.2017
                        montoCompPago = montoCompPago.add(new BigDecimal(map.get("montoComprobantePago").toString()));
                        //******
                        listaMap.add(map);
                    }

                }

            }

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    @FXML
    public void closeOpenDialog2() {
        closePopDialogoPrincipal2();
    }

    public void closePopDialogoPrincipal2() {

        ControladorFormulario controller = AppScreen.getInterfaz(RutasVistas.RUTA_VENTANA_FORMULARIO).getController();

        controller.closePopDialog2();
    }

    void validarNombreArchivo(File selectedFile, String identificador) {

        //Integer periodo = Integer.parseInt(getFechaPeriodo_YYYYMM().substring(5, 6));
        //Nombre del archivo: "0621" + RUC del declarante + período de la declaración + "P" + ".TXT"
        //En el periodo el mes no debe ser mayor al periodo de declaración
        String v0621 = selectedFile.getName().substring(0, 4);
        String vRucDeclarante = selectedFile.getName().substring(4, 15);
        String vPeriodoDeclaracion = selectedFile.getName().substring(15, 21);

        String mensajeBasico = "Nombre del archivo incorrecto";
        nombreArchivoCorrecto = true;

        if (identificador.equals("P.txt") || identificador.equals("PI.txt")) {
        } else {
            nombreArchivoCorrecto = false;
            mensajeError("Error al seleccionar el archivo", mensajeBasico);
            return;
        }
        if (!v0621.equals("0621")) {
            nombreArchivoCorrecto = false;
            mensajeError("Error al seleccionar el archivo", mensajeBasico);
            return;
        }

        int lengthRucDeclarante = vRucDeclarante.length();
        String inicioRucDeclarante = vRucDeclarante.substring(0, 2);
        if (lengthRucDeclarante != 11) {
            nombreArchivoCorrecto = false;
            mensajeError("Error al seleccionar el archivo", mensajeBasico);
            return;
        }
        if (inicioRucDeclarante.equals("10") || inicioRucDeclarante.equals("20")) {
        } else {
            nombreArchivoCorrecto = false;
            mensajeError("Error al seleccionar el archivo", mensajeBasico);
            return;
        }

        if (!RUC_USUARIO.equals(vRucDeclarante)) {
            nombreArchivoCorrecto = false;
            mensajeError("Error al seleccionar el archivo", mensajeBasico);
            return;
        }

//        String vanio = vPeriodoDeclaracion.substring(0, 4);
//        Integer vmes = Integer.parseInt(vPeriodoDeclaracion.substring(4, 6));
//        LocalDate today = LocalDate.now();
//        StringTokenizer st = new StringTokenizer(today.toString(), "-");
//        List lista = new ArrayList<>();
//        while (st.hasMoreElements()) {
//            lista.add(st.nextElement());
//        }
        ControladorFormulario cf = AppScreen.getInterfaz(RutasVistas.RUTA_VENTANA_FORMULARIO).getController();
        if (!vPeriodoDeclaracion.equals(cf.getFechaPeriodo_YYYYMM())) {
            nombreArchivoCorrecto = false;
            mensajeError("Error al seleccionar el archivo", mensajeBasico);
            return;
        }

//        String añoSistema = lista.get(0).toString();
//        if (!vanio.equals(añoSistema)) {
//            nombreArchivoCorrecto = false;
//            mensajeError("Error al seleccionar el archivo", mensajeBasico);
//            return;
//        }
//        Integer mesSistema = Integer.parseInt(lista.get(1).toString());
//        if (vmes > mesSistema) {
//            nombreArchivoCorrecto = false;
//            mensajeError("Error al seleccionar el archivo", mensajeBasico);
//            return;
//        }
    }

    private void llenarTabla_DetalleErrores() {
        try {
            elimnarFilasTabla();

            filaColumn.setCellValueFactory(cellData -> cellData.getValue().filaProperty());
            detalleColumn.setCellValueFactory(cellData -> cellData.getValue().detalleProperty());
            filaColumn.prefWidthProperty().bind(percepcionesTable.widthProperty().multiply(0.1));
            detalleColumn.prefWidthProperty().bind(percepcionesTable.widthProperty().multiply(1.4));
            filaColumn.setResizable(false);
            detalleColumn.setResizable(false);

            Integer index = 1;
            String fila = "";
            String detalle = "";
            List<Map> listaMap1 = new ArrayList<>();
            List lista2 = new ArrayList<>();
            List lista3 = new ArrayList<>();

            for (Map m : listaMap) {

                if (identificador.equals("P.txt")) {

                    String ruc = m.get("ruc").toString();
                    String serieCompPerc = m.get("serieComprobantePercepcion").toString();
                    String numeroCompPerc = m.get("numeroComprobantePercepcion").toString();
                    String fechEmiCompPerc = m.get("fechEmiComprobantePercepcion").toString();
                    String montoCompPerc = m.get("montoComprobantePercepcion").toString();
                    String tipoCompPago = m.get("tipoComprobantePago").toString();
                    String serieCompPago = m.get("serieComprobantePago").toString();
                    String numeroCompPago = m.get("numeroComprobantePago").toString();
                    String fechEmiCompPago = m.get("fechEmiComprobantePago").toString();
                    String valTotalCompPago = m.get("valorTotalComprobantePago").toString();

                    Integer serieComPercInt = 0;
                    Integer numeroCompPercInt = 0;
                    Integer serieCompPagoInt = 0;
                    Integer numeroCompPagoInt = 0;
                    Integer tipoCompPagoInt = 0;

                    StringBuilder lineaLista = new StringBuilder(ruc);
                    StringBuilder lineaLista2 = new StringBuilder(ruc);
                    if (validarNumero(serieCompPerc)) {
                        serieComPercInt = Integer.parseInt(serieCompPerc);
                        lineaLista.append(serieComPercInt.toString());
                        lineaLista2.append(serieComPercInt.toString());

                    } else {
                        lineaLista.append(serieCompPerc);
                        lineaLista2.append(serieCompPerc);
                    }
                    if (validarNumero(numeroCompPerc)) {
                        numeroCompPercInt = Integer.parseInt(numeroCompPerc);
                        lineaLista.append(numeroCompPercInt.toString());
                        lineaLista2.append(numeroCompPercInt.toString());
                    } else {
                        lineaLista.append(numeroCompPerc);
                        lineaLista2.append(numeroCompPerc);
                    }

                    lineaLista2.append(fechEmiCompPerc);
                    lineaLista2.append(montoCompPerc);

                    if (validarNumero(tipoCompPago)) {
                        tipoCompPagoInt = Integer.parseInt(tipoCompPago);
                        lineaLista2.append(tipoCompPagoInt.toString());
                    } else {
                        lineaLista2.append(tipoCompPago);
                    }

                    if (validarNumero(serieCompPago)) {
                        serieCompPagoInt = Integer.parseInt(serieCompPago);
                        lineaLista2.append(serieCompPagoInt.toString());

                    } else {
                        lineaLista2.append(serieCompPago);
                    }
                    if (validarNumero(numeroCompPago)) {
                        numeroCompPagoInt = Integer.parseInt(numeroCompPago);
                        lineaLista2.append(numeroCompPagoInt.toString());
                    } else {
                        lineaLista2.append(numeroCompPago);
                    }

                    if (listaMap1.size() > 0) {//COMPARAR LOS ARREGLOS
                        for (Map m1 : listaMap1) {

                            String lineaLista1 = m1.get("ruc").toString() + m1.get("serieComprobantePercepcion") + m1.get("numeroComprobantePercepcion");

                            String lineaLista3 = m1.get("ruc").toString() + m1.get("serieComprobantePercepcion") + m1.get("numeroComprobantePercepcion")
                                    + m1.get("fechEmiComprobantePercepcion").toString() + m1.get("montoComprobantePercepcion") + m1.get("tipoComprobantePago")
                                    + m1.get("serieComprobantePago") + m1.get("numeroComprobantePago");

                            if (lineaLista2.toString().equals(lineaLista3)) {//2 o más filas con los primeros 8 campos del archivo son iguales
                                lista3.add(index.toString());

                            } else if (lineaLista.toString().equals(lineaLista1)) {//RUC,  serie y Número  del comprobante de percepción es el  mismo 
                                if (!fechEmiCompPerc.equals(m1.get("fechEmiComprobantePercepcion").toString()) || !montoCompPerc.equals(m1.get("montoComprobantePercepcion").toString())) {
                                    lista2.add(index.toString());//Agregar las filas duplicadas que no cumplen con la validación
                                }
                            }

                        }

                    }

                    Map m1 = new HashMap();
                    m1.put("ruc", ruc);
                    if (validarNumero(serieCompPerc)) {//es numero
                        m1.put("serieComprobantePercepcion", serieComPercInt.toString());
                    } else {//es Alfanumerico
                        m1.put("serieComprobantePercepcion", serieCompPerc);
                    }

                    if (validarNumero(numeroCompPerc)) {//es numero
                        m1.put("numeroComprobantePercepcion", numeroCompPercInt.toString());
                    } else {//es Alfanumerico
                        m1.put("numeroComprobantePercepcion", numeroCompPerc);
                    }

                    m1.put("fechEmiComprobantePercepcion", fechEmiCompPerc);
                    m1.put("montoComprobantePercepcion", montoCompPerc);

                    if (validarNumero(tipoCompPago)) {//es numero
                        m1.put("tipoComprobantePago", tipoCompPagoInt.toString());
                    } else {//es Alfanumerico
                        m1.put("tipoComprobantePago", tipoCompPago);
                    }

                    if (validarNumero(serieCompPago)) {//es numero
                        m1.put("serieComprobantePago", serieCompPagoInt.toString());
                    } else {//es Alfanumerico
                        m1.put("serieComprobantePago", serieCompPago);
                    }

                    if (validarNumero(numeroCompPago)) {//es numero
                        m1.put("numeroComprobantePago", numeroCompPagoInt.toString());
                    } else {//es Alfanumerico
                        m1.put("numeroComprobantePago", numeroCompPago);
                    }

                    m1.put("fechEmiComprobantePago", fechEmiCompPago);
                    m1.put("valorTotalComprobantePago", valTotalCompPago);
                    listaMap1.add(m1);//Agregar al arreglo comparador

                    if (!validarRuc(ruc)) {
                        fila = index.toString();
                        detalle = "Número de RUC Invalido";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarRucAgPercVsRucDeclarante(ruc)) {
                        fila = index.toString();
                        detalle = "RUC del agente igual a RUC del declarante";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarFechEmiCompPerc(fechEmiCompPerc)) {//Primero validar la fecha
                    } else if (!validarSerieCompPerc(serieCompPerc, fechEmiCompPerc)) {
                        fila = index.toString();
                        detalle = "La serie del comprobante de percepción no es válida";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarNumeroCompPerc(numeroCompPerc)) {
                        fila = index.toString();
                        detalle = "El número del comprobante de percepción no es válido";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarFechEmiCompPerc(fechEmiCompPerc)) {
                        fila = index.toString();
                        detalle = "La fecha de emisión del comprobante de percepción no es válida";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarFechEmiCompPerc(fechEmiCompPerc)) {//Primero validar la fecha
                    } else {
                        if (!validarFechEmiCompPercMayor14_10_2002(fechEmiCompPerc)) {
                            fila = index.toString();
                            detalle = "La fecha del comprobante de percepción no puede ser menor al 14/10/2002";
                            percepcionesData.add(new PercepcionesProperty(fila, detalle));
                        }

                        if (!validarFechEmiCompPercMayorFechSistema(fechEmiCompPerc)) {
                            fila = index.toString();
                            detalle = "La fecha del sistema es menor a la del comprobante de percepción";
                            percepcionesData.add(new PercepcionesProperty(fila, detalle));
                        }

                        if (!validarFechEmiCompPercMes(fechEmiCompPerc)) {
                            fila = index.toString();
                            detalle = "El mes de la fecha de emisión del comprobante de percepción es mayor que el período declarado";
                            percepcionesData.add(new PercepcionesProperty(fila, detalle));
                        }

                    }

                    /*El importe del comprobante de percepción contiene letras o caracteres no validos
                      El importe del comprobante de percepción contiene más de un punto decimal
                      El importe del comprobante de percepción es demasiado grande
                     */
                    if (!validarMontoCompPercUnPuntoDec(montoCompPerc)) {//Un punto decimal máximo 15 Digitos(12 enteros 2 decimales)
                        fila = index.toString();
                        detalle = "El importe del comprobante de percepción contiene letras o caracteres no validos, \ncontiene más de un punto decimal ó es demasiado grande";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));

                    } else if (!validarMontoCompPerc(montoCompPerc)) {//Cuando el importe es menor a 0.01
                        fila = index.toString();
                        detalle = "El importe del comprobante de percepción no es válido";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }
                    //*** jDelaCruz 20170301
                    if (!validarTipoDocumento(tipoCompPago)) {
                        fila = index.toString();
                        detalle = "No existe el tipo de documento del comprobante de pago";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }
                    //***
                    if (!validarFechEmiCompPago(fechEmiCompPago)) {
                    } else if (!validarSerieCompPago(serieCompPago, fechEmiCompPago, tipoCompPago)) {
                        fila = index.toString();
                        detalle = "La serie del comprobante de pago no es válida";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarNumeroCompPago(numeroCompPago, tipoCompPago)) {
                        fila = index.toString();
                        detalle = "El número del comprobante de pago no es válido";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarFechEmiCompPago(fechEmiCompPago)) {
                        fila = index.toString();
                        detalle = "La fecha de emisión del comprobante de pago no es válida";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    //*** jDelacruz 20170303
                    if (!validarTipoComprob_55_RucAgenteSunat(tipoCompPago, ruc)) {
                        fila = index.toString();
                        detalle = "El tipo de documento del comprobante de pago no es valido";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }
                    //******

                    if (!validarFechEmiCompPago(fechEmiCompPago)) {

                    } else {
                        if (!validarFechEmiCompPagoMenor01_01_2005(fechEmiCompPago)) {
                            fila = index.toString();
                            detalle = "La fecha del comprobante de pago usado como comprobante de percepción no puede ser menor al 01/01/2005";
                            percepcionesData.add(new PercepcionesProperty(fila, detalle));
                        }

                        if (!validarFechEmiCompPagoMayorFechSistema(fechEmiCompPago)) {
                            fila = index.toString();
                            detalle = "La fecha del sistema es menor a la del comprobante de pago";
                            percepcionesData.add(new PercepcionesProperty(fila, detalle));
                        }

                        if (!validarFechEmiCompPagoMes(fechEmiCompPago)) {
                            fila = index.toString();
                            detalle = "La fecha de emisión del doc. origen es mayor que el período declarado";
                            percepcionesData.add(new PercepcionesProperty(fila, detalle));
                        }
                    }

                    if (!validarTipoComprobRucAgenteSunat(tipoCompPago, ruc)) {
                        fila = index.toString();
                        detalle = "Tipo de comprobante de pago inválido para el agente SUNAT";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarValTotalCompPago(valTotalCompPago)) {
                        fila = index.toString();
                        detalle = "El importe del comprobante de pago contiene letras o caracteres no validos, \ncontiene más de un punto decimal ó es demasiado grande";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    } else if (!validarValTotalCompPagoMay(valTotalCompPago)) {
                        fila = index.toString();
                        detalle = "El importe del comprobante de pago no es válido";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                } else if (identificador.equals("PI.txt")) {

                    String ruc = m.get("ruc").toString();
                    String tipoCompPago = m.get("tipoComprobantePago").toString();
                    String serieCompPago = m.get("serieComprobantePago").toString();
                    String numeroCompPago = m.get("numeroComprobantePago").toString();
                    String fechEmiCompPago = m.get("fechEmiComprobantePago").toString();
                    String valTotalCompPago = m.get("montoComprobantePago").toString();

                    Integer serieCompPagoInt = 0;
                    Integer numeroCompPagoInt = 0;
                    Integer tipoCompPagoInt = 0;

                    StringBuilder lineaLista2 = new StringBuilder(ruc);

                    if (validarNumero(tipoCompPago)) {
                        tipoCompPagoInt = Integer.parseInt(tipoCompPago);
                        lineaLista2.append(tipoCompPagoInt.toString());
                    } else {
                        lineaLista2.append(tipoCompPago);
                    }

                    if (validarNumero(serieCompPago)) {
                        serieCompPagoInt = Integer.parseInt(serieCompPago);
                        lineaLista2.append(serieCompPagoInt.toString());

                    } else {
                        lineaLista2.append(serieCompPago);
                    }
                    if (validarNumero(numeroCompPago)) {
                        numeroCompPagoInt = Integer.parseInt(numeroCompPago);
                        lineaLista2.append(numeroCompPagoInt.toString());
                    } else {
                        lineaLista2.append(numeroCompPago);
                    }

                    if (listaMap1.size() > 0) {//COMPARAR LOS ARREGLOS
                        for (Map m1 : listaMap1) {
                            String lineaLista3 = m1.get("ruc").toString() + m1.get("tipoComprobantePago") + m1.get("serieComprobantePago") + m1.get("numeroComprobantePago");

                            if (lineaLista2.toString().equals(lineaLista3)) {//2 o más filas con los primeros 4 campos del archivo son iguales
                                lista3.add(index.toString());

                            }

                        }

                    }

                    Map m1 = new HashMap();
                    m1.put("ruc", ruc);

                    if (validarNumero(tipoCompPago)) {//es numero
                        m1.put("tipoComprobantePago", tipoCompPagoInt.toString());
                    } else {//es Alfanumerico
                        m1.put("tipoComprobantePago", tipoCompPago);
                    }

                    if (validarNumero(serieCompPago)) {//es numero
                        m1.put("serieComprobantePago", serieCompPagoInt.toString());
                    } else {//es Alfanumerico
                        m1.put("serieComprobantePago", serieCompPago);
                    }

                    if (validarNumero(numeroCompPago)) {//es numero
                        m1.put("numeroComprobantePago", numeroCompPagoInt.toString());
                    } else {//es Alfanumerico
                        m1.put("numeroComprobantePago", numeroCompPago);
                    }

                    m1.put("fechEmiComprobantePago", fechEmiCompPago);
                    m1.put("montoComprobantePago", valTotalCompPago);
                    listaMap1.add(m1);//Agregar al arreglo comparador

                    if (!validarRuc(ruc)) {
                        fila = index.toString();
                        detalle = "Número de RUC Invalido";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarRucAgPercVsRucDeclarante(ruc)) {
                        fila = index.toString();
                        detalle = "RUC del agente igual a RUC del declarante";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarRucAgPercVsRucDeclarante(ruc)) {
                        fila = index.toString();
                        detalle = "No puede declarar el RUC de SUNAT en percepciones de ventas internas";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarTipoComprobEnParametro(tipoCompPago)) {
                        fila = index.toString();
                        detalle = "No existe este tipo de comprobante para percepciones de ventas internas";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarFechEmiCompPago(fechEmiCompPago)) {

                    } else if (!validarSerieCompPago(serieCompPago, fechEmiCompPago, tipoCompPago)) {
                        fila = index.toString();
                        detalle = "La serie del comprobante de pago no es válida";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarNumeroCompPago(numeroCompPago, tipoCompPago)) {
                        fila = index.toString();
                        detalle = "El número del comprobante de pago no es válido";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarFechEmiCompPago(fechEmiCompPago)) {
                        fila = index.toString();
                        detalle = "La fecha de emisión del comprobante de pago no es válida";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                    if (!validarFechEmiCompPago(fechEmiCompPago)) {

                    } else {
                        if (!validarFechEmiCompPagoMenor01_01_2005(fechEmiCompPago)) {
                            fila = index.toString();
                            detalle = "La fecha del comprobante de pago usado como comprobante de percepción no puede ser menor al 01/01/2005";
                            percepcionesData.add(new PercepcionesProperty(fila, detalle));
                        }

                        if (!validarFechEmiCompPagoMayorFechSistema(fechEmiCompPago)) {
                            fila = index.toString();
                            detalle = "La fecha del sistema es menor a la del comprobante de pago";
                            percepcionesData.add(new PercepcionesProperty(fila, detalle));
                        }

                        if (!validarFechEmiCompPagoMes(fechEmiCompPago)) {
                            fila = index.toString();
                            detalle = "El mes de la fecha de emisión del comprobante de pago es mayor que el período declarado";
                            percepcionesData.add(new PercepcionesProperty(fila, detalle));
                        }
                    }

                    if (!validarValTotalCompPago(valTotalCompPago)) {
                        fila = index.toString();
                        detalle = "El importe del comprobante de pago contiene letras o caracteres no validos, \ncontiene más de un punto decimal ó es demasiado grande";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    } else if (!validarValTotalCompPagoMay(valTotalCompPago)) {
                        fila = index.toString();
                        detalle = "El importe del comprobante de pago no es válido";
                        percepcionesData.add(new PercepcionesProperty(fila, detalle));
                    }

                }

                index++;
            }//End For

            //***** P - PI****************************************************
            if (lista2.size() > 0) {
                HashSet<String> hashSet = new HashSet<String>(lista2);
                lista2.clear();
                lista2.addAll(hashSet);

                for (int h = 0; h < lista2.size(); h++) {
                    fila = lista2.get(h).toString();
                    detalle = "La fecha y/o el monto del comprobante de  percepción no coincide";
                    percepcionesData.add(new PercepcionesProperty(fila, detalle));
                }

            }

            if (lista3.size() > 0) {
                HashSet<String> hashSet = new HashSet<String>(lista3);
                lista3.clear();
                lista3.addAll(hashSet);

                for (int h = 0; h < lista3.size(); h++) {
                    fila = lista3.get(h).toString();
                    detalle = "El comprobante de pago involucrado es duplicado";
                    percepcionesData.add(new PercepcionesProperty(fila, detalle));
                }

            }
            //******** End P - PI ********************************************

            percepcionesTable.setItems(percepcionesData);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    BigDecimal montoCompPercepcionTemp_2 = BigDecimal.ZERO;
    BigDecimal montoCompPagoTemp_2 = BigDecimal.ZERO;

    @FXML
    public void pintarCasilla_685() {
        //*** jDelacruz 05.04.2017
        try {
            CDialogC171 c171Controller = AppScreen.getInterfaz(RutasFormulario.PATH_CASILLA_171).getController();

            BigDecimal sumaMontos = BigDecimal.ZERO;
            if (identificador.equals("P.txt")) {
                sumaMontos = montoCompPercepcionTemp.add(montoCompPagoTemp);

                if (montoCompPercepcionTemp_2.compareTo(BigDecimal.ZERO) < 0) {//montoCompPercepcionTemp_2 es mayor que 0
                    sumaMontos.subtract(montoCompPercepcionTemp_2);
                }
                c171Controller.getTxt_casilla_685().setText(sumaMontos.toString());

            } else if (identificador.equals("PI.txt")) {
                sumaMontos = montoCompPercepcionTemp.add(montoCompPagoTemp);
                if (montoCompPagoTemp_2.compareTo(BigDecimal.ZERO) < 0) {//montoCompPagoTemp_2 es mayor que 0
                    sumaMontos.subtract(montoCompPagoTemp_2);
                }
                c171Controller.getTxt_casilla_685().setText(sumaMontos.toString());
            }

            btnGuardarPercepciones.setDisable(true);

            montoCompPercepcionTemp_2 = montoCompPercepcionTemp;
            montoCompPagoTemp_2 = montoCompPagoTemp;

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

//    
//    @FXML
//    public void pintarCasilla_685() {
//        
//        try {
//            CDialogC171 c171Controller = AppScreen.getInterfaz(RutasFormulario.PATH_CASILLA_171).getController();
//            
//                if(!importoArchivo){
//                    c171Controller.getTxt_casilla_685().setText("0.00");
//                }
//
//            if (identificador.equals("P.txt")) {
//                montoCompPercepcion = new BigDecimal("0.00");
//
//                for (Map m : listaMap) {
//                    montoCompPercepcion = montoCompPercepcion.add(new BigDecimal(m.get("montoComprobantePercepcion").toString()));
//                }
//
//                if (contRegistrosAceptadosPTemp > -1) {
//                    BigDecimal valorCasilla685 = new BigDecimal(c171Controller.getTxt_casilla_685().getText());
//                    c171Controller.getTxt_casilla_685().setText(valorCasilla685.subtract(montoCompPercepcionTemp).add(montoCompPercepcion).toString());
//
//                    montoCompPercepcionTemp = montoCompPercepcion;
//
//                } else {
//                    BigDecimal valorCasilla685 = new BigDecimal(c171Controller.getTxt_casilla_685().getText());
//                    c171Controller.getTxt_casilla_685().setText(valorCasilla685.add(montoCompPercepcion).toString());
//
//                    montoCompPercepcionTemp = montoCompPercepcion;
//                }
//
//                c171Controller.getTxt_casilla_684().setText("0.00");
//
//                contRegistrosAceptadosPTemp = 1;
//
//            } else if (identificador.equals("PI.txt")) {
//                montoCompPago = new BigDecimal("0.00");
//                for (Map m : listaMap) {
//                    montoCompPago = montoCompPago.add(new BigDecimal(m.get("montoComprobantePago").toString()));
//                }
//
//                if (contRegistrosAceptadosPITemp > -1) {
//                    BigDecimal valorCasilla685 = new BigDecimal(c171Controller.getTxt_casilla_685().getText());
//                    c171Controller.getTxt_casilla_685().setText(valorCasilla685.subtract(montoCompPagoTemp).add(montoCompPago).toString());
//
//                    montoCompPagoTemp = montoCompPago;
//
//                } else {
//                    BigDecimal valorCasilla685 = new BigDecimal(c171Controller.getTxt_casilla_685().getText());
//                    c171Controller.getTxt_casilla_685().setText(valorCasilla685.add(montoCompPago).toString());
//
//                    montoCompPagoTemp = montoCompPago;
//                }
//
//                contRegistrosAceptadosPITemp = 1;
//
//            }
//            btnGuardarPercepciones.setDisable(true);
//            importoArchivo = true;
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
//    
//    listaArchivoP_Temp
    
    
    
    public void llenarCasillas_511_510() {

        if (listaMap.size() > 0 && identificador.equals("P.txt")) {
            contadorTC_55 = 0;
            //for (Map m : listaMap) {
            for (Map m : listaMap) {
                String comprobante55 = m.get("tipoComprobantePago").toString();
                if (comprobante55.equals("55")) {
                    contadorTC_55++;
                }
            }
            can_P = listaMap.size();
        }
        
        if (listaMap.size() > 0 && identificador.equals("PI.txt")) {
            can_PI = listaMap.size();
        }
        
        total_P_PI = can_P + can_PI;
        CASILLA_510 = String.valueOf(total_P_PI);
        CASILLA_511 = String.valueOf(contadorTC_55);
        System.out.println(">>>>>>>>>> CASILLA_510: " + CASILLA_510);
        System.out.println(">>>>>>>>>> CASILLA_511: " + CASILLA_511);
    }

    void mensajeError(String header, String contenido) {
//        Alert alert = new Alert(AlertType.ERROR);
//        alert.setTitle("Aviso");
//        alert.setHeaderText(header);
//        alert.setContentText(contenido);
//        alert.showAndWait();

        AppScreen.FUNCIONES_GENERALES.mostrarMensaje(
                contenido,
                IconoMensaje.ERROR, null);

    }

    public static boolean validarRuc(String ruc) {
        String patron = "^[12]{1}0{1}[0-9]{9}";

        Pattern pat = Pattern.compile(patron);
        Matcher mat = pat.matcher(ruc);
        if (mat.matches()) {
            return true;
        } else {
            return false;
        }
    }

    public boolean validarRucAgPercVsRucDeclarante(String rucAgentePercepcion) {
        boolean flag = true;

        if (rucAgentePercepcion.equals(rucDeclarante)) {
            flag = false;
        }
        return flag;
    }

    public boolean validarRucAgPercIgualRucSunat(String ruc) {
        boolean flag = true;

        if (ruc.equals("20131312955")) {
            flag = false;
        }
        return flag;
    }

    public boolean validarSerieCompPerc(String serieCompPerc, String fechEmiCompPercepcion) {
        boolean flag = true;

        String patron1 = "^([0-9]{4})";//numerico 4 digitos
        Pattern pat1 = Pattern.compile(patron1);
        Matcher mat1 = pat1.matcher(serieCompPerc);

        String patron2 = "^E[0-9]{3}$";//numerico comienza con E 4 digitos..........^9[0-9]{8}$
        Pattern pat2 = Pattern.compile(patron2);
        Matcher mat2 = pat2.matcher(serieCompPerc);

        String patron3 = "^F[a-zA-Z0-9]{3}$";//Alfanumerico comienza con F 4 digitos
        Pattern pat3 = Pattern.compile(patron3);
        Matcher mat3 = pat3.matcher(serieCompPerc);

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/MM/yyyy");
        String fecha1 = "19/07/2010";
        String fecha2 = "01/12/2012";
        LocalDate localDateFECP = LocalDate.parse(fechEmiCompPercepcion, formatter);
        LocalDate localDateFecha1 = LocalDate.parse(fecha1, formatter);
        LocalDate localDateFecha2 = LocalDate.parse(fecha2, formatter);

        String iniSerieCompPerc = serieCompPerc.substring(0, 1);

        if (localDateFECP.isAfter(localDateFecha2) && iniSerieCompPerc.equals("F")) {
            if (!mat3.matches()) {
                flag = false;
            }
        } else if (localDateFECP.isEqual(localDateFecha2) && iniSerieCompPerc.equals("F")) {
            if (!mat3.matches()) {
                flag = false;
            }
        } else if (localDateFECP.isAfter(localDateFecha1) && iniSerieCompPerc.equals("E")) {
            if (!mat2.matches()) {
                flag = false;
            }
        } else if (localDateFECP.isEqual(localDateFecha1) && iniSerieCompPerc.equals("E")) {
            if (!mat2.matches()) {
                flag = false;
            }
        } else if (!mat1.matches()) {
            flag = false;
        }

        return flag;
    }

    public boolean validarNumeroCompPerc(String numeroCompPerc) {
        boolean flag = true;

        String patron1 = "^([0-9]{8})";//Numérico de 8 posiciones 
        Pattern pat1 = Pattern.compile(patron1);
        Matcher mat1 = pat1.matcher(numeroCompPerc);

        if (!mat1.matches()) {
            flag = false;
        }

        return flag;
    }

    public boolean validarFechEmiCompPerc(String fechEmiCompPerc) {
        boolean ok = true;
        try {
            SimpleDateFormat formatoFecha = new SimpleDateFormat("dd/MM/yyyy", Locale.getDefault());
            formatoFecha.setLenient(false);
            formatoFecha.parse(fechEmiCompPerc);

            List lista = new ArrayList<>();
            StringTokenizer st = new StringTokenizer(fechEmiCompPerc, "/");
            while (st.hasMoreTokens()) {
                lista.add(st.nextToken());
            }

            int cont = 0;
            String patron1 = "^([0-9]{4})";//numerico 4 digitos;
            Pattern pat1 = Pattern.compile(patron1);

            Matcher mat1 = pat1.matcher(lista.get(2).toString());

            if (!mat1.matches()) {
                cont++;
            } else {
            }

            String patron2 = "^([0-9]{1,2})";//numerico 4 digitos;
            Pattern pat2 = Pattern.compile(patron2);

            Matcher mat2 = pat2.matcher(lista.get(0).toString());

            if (!mat2.matches()) {
                cont++;
            } else {
            }

            Matcher mat3 = pat2.matcher(lista.get(1).toString());

            if (!mat3.matches()) {
                cont++;
            } else {
            }

            if (cont == 0) {
                int dia = Integer.parseInt(lista.get(0).toString());
                int mes = Integer.parseInt(lista.get(1).toString());
                int año = Integer.parseInt(lista.get(2).toString());
                LocalDate fechaLocal = LocalDate.now();
                int añoSistema = fechaLocal.getYear();

                if (dia == 0 || dia > 31 || mes == 0 || mes > 12 || año == 0 || año > añoSistema) {
                    cont++;
                }
            }

            if (cont > 0) {
                ok = false;
            }

        } catch (ParseException e) {
            ok = false;

        } catch (DateTimeParseException eee) {
            ok = false;
        }

        return ok;
    }

    public boolean validarFechEmiCompPercMayor14_10_2002(String fechEmiCompPerc) {
        boolean flag = true;

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/MM/yyyy");
        String fecha1 = "14/10/2002";

        LocalDate localDateFECP = LocalDate.parse(fechEmiCompPerc, formatter);
        LocalDate localDateFecha1 = LocalDate.parse(fecha1, formatter);

        if (localDateFECP.isBefore(localDateFecha1)) {
            flag = false;
        }

        return flag;
    }

    public boolean validarFechEmiCompPercMayorFechSistema(String fechEmiCompPerc) {
        boolean flag = true;

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/MM/yyyy");
        LocalDate fechSistema = LocalDate.now();
        LocalDate localDateFECP = LocalDate.parse(fechEmiCompPerc, formatter);

        if (localDateFECP.isAfter(fechSistema)) {
            flag = false;
        }

        return flag;

    }

    public boolean validarFechEmiCompPercMes(String fechEmiCompPerc) {
        boolean flag = true;

        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/MM/yyyy");
            LocalDate localDateFECP = LocalDate.parse(fechEmiCompPerc, formatter);
            int mesFECP = localDateFECP.getMonthValue();
            //*** jDelaCruz 20170301
            int anioFECP = localDateFECP.getYear();

            if (anioPeriodoDeclarado >= anioFECP) {
                if (mesFECP > mesPeriodoDeclarado) {
                    flag = false;
                }
            } else {
                flag = false;
            }
            //******
        } catch (Exception e) {
            return false;
        }

        return flag;
    }

    public boolean validarMontoCompPerc(String montoCompPerc) {
        boolean flag = true;
        Double monto = Double.parseDouble(montoCompPerc);

        if (monto < 0.01) {
            flag = false;
        }

        return flag;
    }

    public boolean validarMontoCompPercUnPuntoDec(String montoCompPerc) {
        boolean flag = true;
        //String patron = "^[\\s\\S]{0,5}$";//MÁXIMO 5 DIGITOS
        String patron = "\\d{1,12}\\.?\\d{0,2}";//MÁXIMO 12 ENTEROS Y DOS DECIMALES
        Pattern pat = Pattern.compile(patron);
        Matcher mat = pat.matcher(montoCompPerc);
        if (!mat.matches()) {
            flag = false;
        }

        return flag;
    }

    public boolean validarTipoDocumento(String tipoCompPago) {
        boolean flag = true;

        if (tipoCompPago.equals("01") //Factura
                || tipoCompPago.equals("07") //Nota de Crédito
                || tipoCompPago.equals("08") //Nota de Débito   
                || tipoCompPago.equals("12") //Ticket de Máquina Registradora
                || tipoCompPago.equals("55") //DUA (Solo cuando el RUC del agente de percepción es el de SUNAT 20131312955)
                || tipoCompPago.equals("99") //Otros  
                ) {
            flag = true;
        } else {
            flag = false;
        }

        return flag;
    }

    public boolean validarSerieCompPago(String serieCompPago, String fechEmiCompPago, String tipoCompPago) {
        boolean flag = false;
        try {
            flag = true;
            String patron1 = "^([0-9]{4})";//numerico 4 digitos
            Pattern pat1 = Pattern.compile(patron1);
            Matcher mat1 = pat1.matcher(serieCompPago);

            String patron2 = "^E[0-9]{3}$";//numerico comienza con E 4 digitos..........^9[0-9]{8}$
            Pattern pat2 = Pattern.compile(patron2);
            Matcher mat2 = pat2.matcher(serieCompPago);

            String patron3 = "^F[a-zA-Z0-9]{3}$";//Alfanumerico comienza con F 4 digitos
            Pattern pat3 = Pattern.compile(patron3);
            Matcher mat3 = pat3.matcher(serieCompPago);

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/MM/yyyy");
            String fecha1 = "19/07/2010";
            String fecha2 = "01/12/2012";
            LocalDate localDateFECP = LocalDate.parse(fechEmiCompPago, formatter);
            LocalDate localDateFecha1 = LocalDate.parse(fecha1, formatter);
            LocalDate localDateFecha2 = LocalDate.parse(fecha2, formatter);

            String iniSerieCompPerc = serieCompPago.substring(0, 1);

            if (tipoCompPago.equals("01") || tipoCompPago.equals("08")) {//01:FACTURA. 08:NOTA DE DÉBITO

                if (localDateFECP.isAfter(localDateFecha2) && iniSerieCompPerc.equals("F")) {
                    if (!mat3.matches()) {
                        flag = false;
                    }
                } else if (localDateFECP.isEqual(localDateFecha2) && iniSerieCompPerc.equals("F")) {
                    if (!mat3.matches()) {
                        flag = false;
                    }
                } else if (localDateFECP.isAfter(localDateFecha1) && iniSerieCompPerc.equals("E")) {
                    if (!mat2.matches()) {
                        flag = false;
                    }
                } else if (localDateFECP.isEqual(localDateFecha1) && iniSerieCompPerc.equals("E")) {
                    if (!mat2.matches()) {
                        flag = false;
                    }
                } else if (!mat1.matches()) {
                    flag = false;
                }

            } else if (!mat1.matches()) {
                flag = false;
            }
        } catch (Exception e) {
        }

        return flag;
    }

    boolean validarNumeroCompPago(String numeroCompPago, String tipoCompPago) {
        boolean flag = true;
        String patron1 = "^([0-9]{1,8})";//numerico 8 digitos
        Pattern pat1 = Pattern.compile(patron1);
        Matcher mat1 = pat1.matcher(numeroCompPago);

        String patron2 = "^([0-9]{1,15})";//numerico 15 digitos
        Pattern pat2 = Pattern.compile(patron2);
        Matcher mat2 = pat2.matcher(numeroCompPago);

        if (tipoCompPago.equals("99")) {//99: OTROS
            if (!mat2.matches()) {
                flag = false;
            }
        } else if (!mat1.matches()) {
            flag = false;
        }

        return flag;
    }

    public boolean validarFechEmiCompPago(String fechEmiCompPago) {

        boolean ok = true;
        try {
            SimpleDateFormat formatoFecha = new SimpleDateFormat("dd/MM/yyyy", Locale.getDefault());
            formatoFecha.setLenient(false);
            formatoFecha.parse(fechEmiCompPago);

            List lista = new ArrayList<>();
            StringTokenizer st = new StringTokenizer(fechEmiCompPago, "/");
            while (st.hasMoreTokens()) {
                lista.add(st.nextToken());
            }

            int cont = 0;
            String patron1 = "^([0-9]{4})";//numerico 4 digitos;
            Pattern pat1 = Pattern.compile(patron1);

            Matcher mat1 = pat1.matcher(lista.get(2).toString());

            if (!mat1.matches()) {
                cont++;
            } else {
            }

            String patron2 = "^([0-9]{1,2})";//numerico 4 digitos;
            Pattern pat2 = Pattern.compile(patron2);

            Matcher mat2 = pat2.matcher(lista.get(0).toString());

            if (!mat2.matches()) {
                cont++;
            } else {
            }

            Matcher mat3 = pat2.matcher(lista.get(1).toString());

            if (!mat3.matches()) {
                cont++;
            } else {
            }

            if (cont == 0) {
                int dia = Integer.parseInt(lista.get(0).toString());
                int mes = Integer.parseInt(lista.get(1).toString());
                int año = Integer.parseInt(lista.get(2).toString());
                LocalDate fechaLocal = LocalDate.now();
                int añoSistema = fechaLocal.getYear();

                if (dia == 0 || dia > 31 || mes == 0 || mes > 12 || año == 0 || año > añoSistema) {
                    cont++;
                }
            }

            if (cont > 0) {
                ok = false;
            }

        } catch (ParseException e) {
            ok = false;

        } catch (DateTimeParseException eee) {
            ok = false;
        }

        return ok;

    }

    public boolean validarFechEmiCompPagoMenor01_01_2005(String fechEmiCompPago) {//Cuando la fechas de emisión del comprobante de pago es menor al 01/01/2005
        boolean flag = false;
        try {
            flag = true;

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/MM/yyyy");
            String fecha1 = "01/01/2005";

            LocalDate localDateFECP = LocalDate.parse(fechEmiCompPago, formatter);
            LocalDate localDateFecha1 = LocalDate.parse(fecha1, formatter);

            if (localDateFECP.isBefore(localDateFecha1)) {
                flag = false;
            }
        } catch (Exception e) {
        }
        return flag;
    }

    public boolean validarFechEmiCompPagoMayorFechSistema(String fechEmiCompPago) {
        boolean flag = false;
        try {
            flag = true;

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/MM/yyyy");
            LocalDate fechSistema = LocalDate.now();
            LocalDate localDateFECP = LocalDate.parse(fechEmiCompPago, formatter);

            if (localDateFECP.isAfter(fechSistema)) {
                flag = false;
            }
        } catch (Exception e) {
        }

        return flag;
    }

    public boolean validarFechEmiCompPagoMes(String fechEmiCompPago) {
        boolean flag = true;

        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/MM/yyyy");
            LocalDate localDateFECP = LocalDate.parse(fechEmiCompPago, formatter);
            int mesFECP = localDateFECP.getMonthValue();
            //*** jDelaCruz 20170301
            int anioFECP = localDateFECP.getYear();

            if (anioPeriodoDeclarado >= anioFECP) {
                if (mesFECP > mesPeriodoDeclarado) {
                    flag = false;
                }
            } else {
                flag = false;
            }
            //******
        } catch (Exception e) {
            return false;
        }

        //******
        return flag;
    }

    //Tipo de comprobante de pago inválido para el agente SUNAT
    public boolean validarTipoComprobRucAgenteSunat(String tipoCompPago, String ruc) {
        //Cuando el RUC del agente de percepción ingresado sea el de la SUNAT (RUC 20131312955) y el tipo de comprobante de pago sea diferente a: 07 - Nota de Crédito,  08 – Nota de Débito y 55 – Declaración Única de Aduanas (DUA).
        boolean flag = true;

        if (ruc.equals("20131312955")) {//SUNAT (RUC 20131312955)
            //07 - Nota de Crédito,  08 – Nota de Débito y 55 – Declaración Única de Aduanas (DUA)
            if (tipoCompPago.equals("07") || tipoCompPago.equals("08") || tipoCompPago.equals("55")) {
            } else {
                flag = false;
            }
        }
        return flag;
    }

    //*** jDelacruz 20170303
    //El tipo de documento del comprobante de pago no es valido
    public boolean validarTipoComprob_55_RucAgenteSunat(String tipoCompPago, String ruc) {
        //Cuando el RUC del agente de percepción ingresado sea el de la SUNAT (RUC 20131312955) y el tipo de comprobante de pago sea diferente a: 07 - Nota de Crédito,  08 – Nota de Débito y 55 – Declaración Única de Aduanas (DUA).
        boolean flag = true;

        if (tipoCompPago.equals("55") && !ruc.equals("20131312955")) {//SUNAT (RUC 20131312955)
            //07 - Nota de Crédito,  08 – Nota de Débito y 55 – Declaración Única de Aduanas (DUA)
            flag = false;
        }
        return flag;
    }
    //******

    //No existe este tipo de comprobante para percepciones de ventas internas
    public boolean validarTipoComprobEnParametro(String tipoCompPago) {
        boolean flag = true;
        //01 Factura. 08 Nota de Débito. 12 Ticket de Máquina Registradora. 99 Otros
        if (tipoCompPago.equals("01") || tipoCompPago.equals("08") || tipoCompPago.equals("12") || tipoCompPago.equals("99")) {
            flag = true;
        } else {
            flag = false;
        }
        return flag;
    }

    public static boolean validarNumero(String numero) {
        boolean flag = true;

        String patron1 = "[0-9]*";//Numérico de 8 posiciones 
        Pattern pat1 = Pattern.compile(patron1);
        Matcher mat1 = pat1.matcher(numero);

        if (mat1.matches()) {
            flag = true;
        } else {
            flag = false;
        }

        return flag;
    }

    public boolean validarValTotalCompPagoMay(String valTotalCompPago) {
        boolean flag = true;
        Double monto = Double.parseDouble(valTotalCompPago);

        if (monto < 0.01) {
            flag = false;
        }

        return flag;
    }

    public boolean validarValTotalCompPago(String valTotalCompPago) {
        boolean flag = true;
        //String patron = "^[\\s\\S]{0,5}$";//MÁXIMO 5 DIGITOS
        String patron = "\\d{1,12}\\.?\\d{0,2}";//MÁXIMO 12 ENTEROS Y DOS DECIMALES
        Pattern pat = Pattern.compile(patron);
        Matcher mat = pat.matcher(valTotalCompPago);
        if (!mat.matches()) {
            flag = false;
        }

        return flag;
    }

    public void elimnarFilasTabla() {
        int filas = percepcionesTable.getItems().size();

        for (int i = 0; filas > i; i++) {
            percepcionesData.remove(0);
        }
    }

    public void mostrarRegistrosCargados_Rechazados() {
        List filasList = new ArrayList<>();
        percepcionesTable.getItems().forEach(item -> filasList.add(item.getFila()));
        HashSet<String> hashSet = new HashSet<String>(filasList);
        filasList.clear();
        filasList.addAll(hashSet);

        String cargados = String.valueOf(listaMap.size() - filasList.size());
        lblRegistCargados.setText(cargados);
        lblRegistRechazados.setText(String.valueOf(filasList.size()));

    }

    @FXML
    public void OcultarMensaje() {
        /*
        if (vbMensajePercepciones.getPrefHeight() == 0) {
            vbMensajePercepciones.setVisible(true);
            vbMensajePercepciones.setPrefHeight(60);
        } else {
            vbMensajePercepciones.setVisible(false);
            vbMensajePercepciones.setPrefHeight(0);
        }*/
        recursivoDesaparecer(vbMensajePercepciones);
    }

    private void recursivoDesaparecer(Node nodo) {
        if (nodo instanceof Pane) {
            ((Pane) nodo).getChildren().forEach((n) -> {
                recursivoDesaparecer(n);
            });
            ((Pane) nodo).setMinHeight(0);
            ((Pane) nodo).setPrefHeight(0);
            ((Pane) nodo).setMaxHeight(0);
        }
        (nodo).setVisible(false);
    }

}
