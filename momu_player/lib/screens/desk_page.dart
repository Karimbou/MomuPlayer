// Import necessary Flutter packages and local components and controllers
import 'package:flutter/material.dart';
import 'package:momu_player/components/sound_key.dart';
import 'package:momu_player/constants.dart';
import 'package:momu_player/audio/audio_controller.dart';
import 'settings_page.dart';

// Main DeskPage widget that serves as the primary screen for the sound pads
class DeskPage extends StatefulWidget {
  final String title;
  final AudioController audioController; // Controller to handle audio playback

  const DeskPage({
    super.key,
    required this.title,
    required this.audioController,
  });
  @override
  State<DeskPage> createState() => _DeskPageState();
}

// Enum to define available filter types
enum Filter { off, reverb, delay }

class _DeskPageState extends State<DeskPage> {
  double wetValue = 0.1; // Controls the intensity of the audio effect
  Filter selectedFilter = Filter.off; // Currently selected audio filter

  @override
  void initState() {
    super.initState();
    // Wait for audio controller to initialize before updating UI
    widget.audioController.initialized.then((_) {
      if (mounted) setState(() {});
    });
  }

  // Handler for when user changes the filter type
  void _handleFilterChange(Set<Filter> value) {
    setState(() {
      selectedFilter = value.first;
      _applyFilter();
    });
  }

  // Applies the selected filter with current wetValue
  void _applyFilter() {
    switch (selectedFilter) {
      case Filter.reverb:
        // Apply reverb effect
        widget.audioController.soloud.filters.freeverbFilter.wet.value =
            wetValue;
        widget.audioController.soloud.filters.echoFilter.wet.value = 0.0;
        break;
      case Filter.delay:
        // Apply delay effect
        widget.audioController.soloud.filters.echoFilter.wet.value = wetValue;
        widget.audioController.soloud.filters.freeverbFilter.wet.value = 0.0;
        break;
      case Filter.off:
        // Turn off all effects
        widget.audioController.soloud.filters.freeverbFilter.wet.value = 0.0;
        widget.audioController.soloud.filters.echoFilter.wet.value = 0.0;
        break;
    }
  }

  // Creates a row of sound keys based on provided configurations
  Widget _buildSoundKeyRow(List<SoundKeyConfig> configs) {
    return Expanded(
      child: Row(
        children: configs
            .map((config) => Expanded(
                  child: SoundKey(
                    onPress: () => config.soundPath != null
                        ? widget.audioController.playSound(config.soundPath!)
                        : null,
                    colour: config.color,
                  ),
                ))
            .toList(),
      ),
    );
  }

  // Builds the filter control section UI
  Widget _buildFilterSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Filter Section',
              style: kSliderTextStyle,
            ),
          ),
          Expanded(
            child: _buildFilterButtons(),
          ),
          Expanded(child: _buildEffectSlider()),
          const SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  // Creates segmented buttons for filter selection
  Widget _buildFilterButtons() {
    return SegmentedButtonTheme(
      data: SegmentedButtonTheme.of(context).copyWith(
        style: const ButtonStyle(
          alignment: Alignment.center,
        ),
      ),
      child: SegmentedButton<Filter>(
        segments: const <ButtonSegment<Filter>>[
          ButtonSegment<Filter>(
            value: Filter.reverb,
            label: Text('Reverb'),
          ),
          ButtonSegment<Filter>(
            value: Filter.delay,
            label: Text('Delay'),
          ),
          ButtonSegment<Filter>(
            value: Filter.off,
            label: Text('Off'),
          ),
        ],
        selected: {selectedFilter},
        onSelectionChanged: _handleFilterChange,
      ),
    );
  }

  // Creates a slider to control effect intensity
  Widget _buildEffectSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        // Customize slider appearance
        activeTrackColor: Colors.white,
        inactiveTrackColor: const Color(0xFF8D8E98),
        thumbColor: const Color(0xffeb1555),
        overlayColor: const Color(0x29eb1555),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 18.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 35.0),
      ),
      child: Column(
        children: [
          const Text(
            'Effect Intensity',
            style: kSliderTextStyle,
          ),
          Slider(
            value: wetValue,
            min: 0.1,
            max: 1.0,
            onChanged: (double newValue) {
              setState(() {
                wetValue = newValue;
                _applyFilter();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define configuration for sound keys including colors and sound paths
    final soundKeyConfigs = [
      [
        const SoundKeyConfig(color: kTabColorGreen, soundPath: 'wurli_c'),
        const SoundKeyConfig(color: kTabColorBlue, soundPath: 'wurli_d'),
      ],
      [
        const SoundKeyConfig(color: kTabColorOrange, soundPath: 'wurli_e'),
        const SoundKeyConfig(color: kTabColorPink, soundPath: 'wurli_f'),
      ],
      [
        const SoundKeyConfig(color: kTabColorYellow, soundPath: 'wurli_g'),
        const SoundKeyConfig(color: kTabColorPurple, soundPath: 'wurli_a'),
      ],
      [
        const SoundKeyConfig(color: kTabColorWhite, soundPath: 'wurli_b'),
        const SoundKeyConfig(color: kTabColorRed, soundPath: 'wurli_c_oc'),
      ],
    ];

    // Build the main screen layout
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Settings button in app bar
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    audioController: widget.audioController,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      // Main body layout with sound keys and filter section
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ...soundKeyConfigs.map(_buildSoundKeyRow),
          _buildFilterSection(),
        ],
      ),
    );
  }
}