import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../models/device_data.dart';
import 'home_viewmodel.dart';

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..forward();

    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool _isValueCritical(String status) {
    return status.contains('!');
  }

  Widget _buildPulsingCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      String status,
      bool isCritical,
      ) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isCritical
            ? 1.0 + (_pulseController.value * 0.05)  // Pulse effect for critical values
            : 1.0;
        final glowOpacity = isCritical
            ? 0.5 + (_pulseController.value * 0.5)   // Glow effect for critical values
            : 0.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: isCritical ? [
                BoxShadow(
                  color: color.withOpacity(glowOpacity),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ] : [],
            ),
            child: _buildMetricCard(context, title, value, icon, color, status),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      String status,
      ) {
    final isCritical = _isValueCritical(status);

    return Card(
      elevation: isCritical ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isCritical
            ? BorderSide(color: color.withOpacity(0.5), width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withOpacity(0.2),
            ],
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPulsingIcon(icon, color, isCritical),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            SizedBox(height: 10),
            _buildPulsingValue(value, color, isCritical),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingIcon(IconData icon, Color color, bool isCritical) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isCritical
            ? 1.0 + (_pulseController.value * 0.2)
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: Icon(
            icon,
            size: 40,
            color: color,
          ),
        );
      },
    );
  }

  Widget _buildPulsingValue(String value, Color color, bool isCritical) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final opacity = isCritical
            ? 0.5 + (_pulseController.value * 0.5)
            : 1.0;

        return Text(
          value,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(opacity),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    final isWarning = status.contains('!');
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowOpacity = isWarning
            ? 0.3 + (_pulseController.value * 0.7)
            : 0.2;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isWarning
                ? Colors.red.withOpacity(glowOpacity)
                : Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isWarning ? Colors.red : Colors.green,
              width: 1.5,
            ),
            boxShadow: isWarning ? [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: -2,
              )
            ] : [],
          ),
          child: Text(
            status,
            style: TextStyle(
              color: isWarning ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (model) => model.initialize(),
      builder: (context, model, child) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Health Monitor',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E),
                Color(0xFF0D47A1),
                Color(0xFF311B92),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: StreamBuilder<DeviceData>(
                stream: model.getDeviceDataStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }
              
                  if (!snapshot.hasData) {
                    return _buildLoadingState();
                  }
              
                  final data = snapshot.data!;
                  return FadeTransition(
                    opacity: _fadeController,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutQuart,
                            )),
                            child: _buildPulsingCard(
                              context,
                              'Oxygen Level',
                              '${data.oxigen.toStringAsFixed(1)}%',
                              Icons.air_rounded,
                              Color(0xFF64B5F6),
                              model.oxygenStatus,
                              _isValueCritical(model.oxygenStatus),
                            ),
                          ),
                          SizedBox(height: 20),
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutQuart,
                            )),
                            child: _buildPulsingCard(
                              context,
                              'Alcohol Level',
                              '${data.alcohol.toStringAsFixed(3)}%',
                              Icons.local_drink_rounded,
                              Color(0xFFE57373),
                              model.alcoholStatus,
                              _isValueCritical(model.alcoholStatus),
                            ),
                          ),
                          SizedBox(height: 20),
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutQuart,
                            )),
                            child: _buildPulsingCard(
                              context,
                              'Temperature',
                              '${data.temperature.toStringAsFixed(1)}°C',
                              Icons.thermostat_rounded,
                              Color(0xFFFFB74D),
                              model.temperatureStatus,
                              _isValueCritical(model.temperatureStatus),
                            ),
                          ),
                          SizedBox(height: 20,),
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutQuart,
                            )),
                            child: _buildPulsingCard(
                              context,
                              'Heart Rate',
                              '${data.bpm.toStringAsFixed(1)}',
                              Icons.monitor_heart,
                              Color(0xFFFF0000),
                              model.bpmStatus,
                              _isValueCritical(model.bpmStatus),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
          ),
          SizedBox(height: 20),
          Text(
            'Loading data...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[300],
              size: 60,
            ),
            SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}