<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Sistema de Votació - Claustre</title>
    
    <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-database-compat.js"></script>
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        .container {
            flex: 1;
            max-width: 100%;
            width: 100%;
            margin: 0 auto;
            padding: 20px;
        }
        
        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
            font-size: 1.5rem;
        }
        
        .pantalla-seleccion {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        
        .votacion-card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            cursor: pointer;
            transition: all 0.3s;
            border: 3px solid transparent;
        }
        
        .votacion-card:active {
            transform: scale(0.98);
        }
        
        .votacion-card.votado {
            background: #e8f5e9;
            border-color: #4CAF50;
            opacity: 0.8;
            cursor: not-allowed;
        }
        
        .votacion-card.votado::after {
            content: " ✅ JA HAS VOTAT";
            display: block;
            margin-top: 10px;
            font-weight: bold;
            color: #4CAF50;
        }
        
        .votacion-titulo {
            font-weight: bold;
            font-size: 1.2rem;
            margin-bottom: 5px;
        }
        
        .votacion-estado {
            color: #666;
            font-size: 0.9rem;
        }
        
        .btn-disabled {
            opacity: 0.5;
            pointer-events: none;
        }
        
        .pantalla-votacion {
            display: none;
            flex-direction: column;
            height: 100%;
        }
        
        .pregunta-titulo {
            background: white;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 20px;
            text-align: center;
            font-size: 1.2rem;
            font-weight: bold;
            color: #333;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .botones-voto {
            display: flex;
            flex-direction: column;
            gap: 15px;
            flex: 1;
            justify-content: center;
        }
        
        .btn-voto {
            padding: 40px 20px;
            font-size: 2rem;
            font-weight: bold;
            border: none;
            border-radius: 16px;
            cursor: pointer;
            transition: all 0.2s;
            text-transform: uppercase;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        
        .btn-voto:active { transform: scale(0.95); }
        
        .btn-si { background: linear-gradient(135deg, #4CAF50, #45a049); color: white; }
        .btn-no { background: linear-gradient(135deg, #f44336, #d32f2f); color: white; }
        .btn-blanc { background: linear-gradient(135deg, #9e9e9e, #757575); color: white; }
        
        .btn-ver-resultados {
            margin-top: 20px;
            padding: 20px;
            background: #2196F3;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1.2rem;
            cursor: pointer;
        }
        
        .pantalla-resultados {
            display: none;
            flex-direction: column;
            height: 100%;
        }
        
        .header-resultados {
            background: white;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .titulo-votacion {
            font-size: 1.1rem;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }
        
        .contador-votantes {
            font-size: 1rem;
            color: #666;
        }
        
        .grafico-container {
            background: white;
            border-radius: 12px;
            padding: 20px;
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: flex-end;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .barras-vertical {
            display: flex;
            justify-content: space-around;
            align-items: flex-end;
            height: 300px;
            gap: 20px;
        }
        
        .barra-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            flex: 1;
        }
        
        .barra {
            width: 100%;
            max-width: 80px;
            border-radius: 8px 8px 0 0;
            transition: height 0.5s ease;
            position: relative;
            min-height: 10px;
        }
        
        .barra-si { background: #4CAF50; }
        .barra-no { background: #f44336; }
        .barra-blanc { background: #9e9e9e; }
        
        .barra-valor {
            position: absolute;
            top: -30px;
            left: 50%;
            transform: translateX(-50%);
            font-weight: bold;
            font-size: 1.2rem;
        }
        
        .barra-label {
            margin-top: 10px;
            font-weight: bold;
            font-size: 1rem;
        }
        
        .barra-porcentaje {
            font-size: 0.9rem;
            color: #666;
        }
        
        .btn-volver {
            margin-top: 20px;
            padding: 20px;
            background: #FF9800;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1.2rem;
            cursor: pointer;
        }
        
        .mensaje-votado {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: #4CAF50;
            color: white;
            padding: 30px 40px;
            border-radius: 16px;
            font-size: 1.3rem;
            font-weight: bold;
            display: none;
            z-index: 1000;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        
        .ya-votado-info {
            background: #fff3cd;
            border: 2px solid #ffc107;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
            color: #856404;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- PANTALLA 1: SELECCIONAR VOTACIÓN -->
        <div id="pantallaSeleccion" class="pantalla-seleccion">
            <h1>🗳️ Sistema de Votació</h1>
            <p style="text-align: center; color: #666; margin-bottom: 20px;">
                Toca una votació per participar
            </p>
            
            <div id="listaVotaciones"></div>
        </div>

        <!-- PANTALLA 2: BOTONES DE VOTO -->
        <div id="pantallaVotacion" class="pantalla-votacion">
            <div id="preguntaVotacion" class="pregunta-titulo"></div>
            
            <div id="yaVotadoMensaje" class="ya-votado-info" style="display: none;">
                ⚠️ Ja has votat en aquesta votació. Pots veure els resultats.
            </div>
            
            <div id="botonesVoto" class="botones-voto">
                <button onclick="votar('si')" class="btn-voto btn-si">✅ SÍ</button>
                <button onclick="votar('no')" class="btn-voto btn-no">❌ NO</button>
                <button onclick="votar('blanc')" class="btn-voto btn-blanc">⚪ BLANC</button>
            </div>
            
            <button onclick="irAResultados()" class="btn-ver-resultados">
                📊 Veure Resultats en Directe
            </button>
        </div>

        <!-- PANTALLA 3: RESULTADOS -->
        <div id="pantallaResultados" class="pantalla-resultados">
            <div class="header-resultados">
                <div id="tituloResultado" class="titulo-votacion"></div>
                <div class="contador-votantes">
                    👥 Persones que han votat: <span id="totalVotantes">0</span>
                </div>
            </div>
            
            <div class="grafico-container">
                <div class="barras-vertical">
                    <div class="barra-item">
                        <div class="barra barra-si" id="barraSi" style="height: 5%">
                            <span class="barra-valor" id="valorSi">0</span>
                        </div>
                        <div class="barra-label">SÍ</div>
                        <div class="barra-porcentaje" id="pctSi">0%</div>
                    </div>
                    <div class="barra-item">
                        <div class="barra barra-no" id="barraNo" style="height: 5%">
                            <span class="barra-valor" id="valorNo">0</span>
                        </div>
                        <div class="barra-label">NO</div>
                        <div class="barra-porcentaje" id="pctNo">0%</div>
                    </div>
                    <div class="barra-item">
                        <div class="barra barra-blanc" id="barraBlanc" style="height: 5%">
                            <span class="barra-valor" id="valorBlanc">0</span>
                        </div>
                        <div class="barra-label">BLANC</div>
                        <div class="barra-porcentaje" id="pctBlanc">0%</div>
                    </div>
                </div>
            </div>
            
            <button onclick="volverAInicio()" class="btn-volver">
                🔄 Tornar a les Votacions
            </button>
        </div>

        <div id="mensajeVotado" class="mensaje-votado">
            ✅ Vot registrat!
        </div>
    </div>

    <script>
        // 🔥 CONFIGURACIÓN FIREBASE - REEMPLAZAR CON TUS DATOS
        const firebaseConfig = {
            apiKey: "TU_API_KEY",
            authDomain: "TU_PROYECTO.firebaseapp.com",
            databaseURL: "https://TU_PROYECTO-default-rtdb.firebaseio.com",
            projectId: "TU_PROYECTO",
            storageBucket: "TU_PROYECTO.appspot.com",
            messagingSenderId: "123456789",
            appId: "1:123456789:web:abcdef"
        };

        firebase.initializeApp(firebaseConfig);
        const database = firebase.database();

        // Datos de votaciones
        const votacionesData = {
            'votacion1': { titulo: '📋 Votació 1: Pressupost anual', activa: true },
            'votacion2': { titulo: '📋 Votació 2: Calendari escolar', activa: true },
            'votacion3': { titulo: '📋 Votació 3: Normativa interna', activa: true }
        };

        let votacionActual = null;
        let votacionRef = null;

        // Generar ID único del dispositivo (se guarda en localStorage)
        function getDeviceId() {
            let deviceId = localStorage.getItem('device_voter_id');
            if (!deviceId) {
                deviceId = 'voter_' + Math.random().toString(36).substr(2, 9) + Date.now();
                localStorage.setItem('device_voter_id', deviceId);
            }
            return deviceId;
        }

        // Verificar si ya votó en esta votación
        function yaVotoEn(votacionId) {
            const votosRealizados = JSON.parse(localStorage.getItem('votos_realizados') || '[]');
            return votosRealizados.includes(votacionId);
        }

        // Marcar como votado
        function marcarComoVotado(votacionId) {
            const votosRealizados = JSON.parse(localStorage.getItem('votos_realizados') || '[]');
            if (!votosRealizados.includes(votacionId)) {
                votosRealizados.push(votacionId);
                localStorage.setItem('votos_realizados', JSON.stringify(votosRealizados));
            }
        }

        // Renderizar lista de votaciones
        function renderizarVotaciones() {
            const container = document.getElementById('listaVotaciones');
            container.innerHTML = '';
            
            Object.keys(votacionesData).forEach(key => {
                const voto = votacionesData[key];
                const yaVoto = yaVotoEn(key);
                
                const card = document.createElement('div');
                card.className = 'votacion-card' + (yaVoto ? ' votado' : '');
                card.innerHTML = `
                    <div class="votacion-titulo">${voto.titulo}</div>
                    <div class="votacion-estado">
                        ${yaVoto ? 'Has participat en aquesta votació' : 'Toca per votar'}
                    </div>
                `;
                
                card.onclick = () => entrarAVotar(key);
                container.appendChild(card);
            });
        }

        // Entrar a votar
        function entrarAVotar(votacionId) {
            if (yaVotoEn(votacionId)) {
                // Si ya votó, ir directo a resultados
                votacionActual = votacionId;
                mostrarPantalla('pantallaVotacion');
                document.getElementById('preguntaVotacion').textContent = votacionesData[votacionId].titulo;
                document.getElementById('yaVotadoMensaje').style.display = 'block';
                document.getElementById('botonesVoto').style.display = 'none';
                return;
            }
            
            votacionActual = votacionId;
            mostrarPantalla('pantallaVotacion');
            document.getElementById('preguntaVotacion').textContent = votacionesData[votacionId].titulo;
            document.getElementById('yaVotadoMensaje').style.display = 'none';
            document.getElementById('botonesVoto').style.display = 'flex';
        }

        // Votar
        function votar(tipo) {
            if (!votacionActual || yaVotoEn(votacionActual)) {
                alert('Ja has votat!');
                return;
            }
            
            // Registrar voto en Firebase
            const ref = database.ref('votaciones/' + votacionActual + '/' + tipo);
            ref.transaction(current => (current || 0) + 1);
            
            const refTotal = database.ref('votaciones/' + votacionActual + '/totalVotantes');
            refTotal.transaction(current => (current || 0) + 1);
            
            // Registrar participación con ID de dispositivo
            const deviceId = getDeviceId();
            database.ref('votaciones/' + votacionActual + '/participantes/' + deviceId).set({
                voto: tipo,
                timestamp: Date.now()
            });
            
            // Marcar en localStorage
            marcarComoVotado(votacionActual);
            
            // Mostrar confirmación
            const mensaje = document.getElementById('mensajeVotado');
            mensaje.style.display = 'block';
            setTimeout(() => {
                mensaje.style.display = 'none';
                irAResultados();
            }, 1500);
        }

        // Ir a resultados
        function irAResultados() {
            if (!votacionActual) return;
            
            mostrarPantalla('pantallaResultados');
            document.getElementById('tituloResultado').textContent = votacionesData[votacionActual].titulo;
            
            if (votacionRef) votacionRef.off();
            
            votacionRef = database.ref('votaciones/' + votacionActual);
            votacionRef.on('value', snapshot => {
                actualizarGrafico(snapshot.val() || { si: 0, no: 0, blanc: 0, totalVotantes: 0 });
            });
        }

        // Actualizar gráfico
        function actualizarGrafico(datos) {
            const si = datos.si || 0;
            const no = datos.no || 0;
            const blanc = datos.blanc || 0;
            const total = datos.totalVotantes || 0;
            
            document.getElementById('totalVotantes').textContent = total;
            
            document.getElementById('valorSi').textContent = si;
            document.getElementById('valorNo').textContent = no;
            document.getElementById('valorBlanc').textContent = blanc;
            
            const totalVotos = si + no + blanc;
            const maxValor = Math.max(si, no, blanc, 1);
            
            document.getElementById('barraSi').style.height = Math.max(5, (si / maxValor) * 100) + '%';
            document.getElementById('barraNo').style.height = Math.max(5, (no / maxValor) * 100) + '%';
            document.getElementById('barraBlanc').style.height = Math.max(5, (blanc / maxValor) * 100) + '%';
            
            document.getElementById('pctSi').textContent = totalVotos > 0 ? ((si / totalVotos) * 100).toFixed(1) + '%' : '0%';
            document.getElementById('pctNo').textContent = totalVotos > 0 ? ((no / totalVotos) * 100).toFixed(1) + '%' : '0%';
            document.getElementById('pctBlanc').textContent = totalVotos > 0 ? ((blanc / totalVotos) * 100).toFixed(1) + '%' : '0%';
        }

        // Volver a inicio
        function volverAInicio() {
            if (votacionRef) votacionRef.off();
            votacionActual = null;
            renderizarVotaciones();
            mostrarPantalla('pantallaSeleccion');
        }

        // Helper mostrar pantalla
        function mostrarPantalla(id) {
            ['pantallaSeleccion', 'pantallaVotacion', 'pantallaResultados'].forEach(p => {
                document.getElementById(p).style.display = p === id ? (p === 'pantallaSeleccion' ? 'flex' : (p === 'pantallaVotacion' ? 'flex' : 'flex')) : 'none';
                if (p !== id) document.getElementById(p).style.display = 'none';
            });
            if (id === 'pantallaSeleccion') {
                document.getElementById('pantallaSeleccion').style.display = 'flex';
                document.getElementById('pantallaSeleccion').style.flexDirection = 'column';
            }
        }

        // Inicializar
        renderizarVotaciones();
    </script>
</body>
</html>
