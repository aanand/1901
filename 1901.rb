require 'bloops'

class Song
  attr_reader :bloops, :length

  def initialize(bloops, &block)
    @bloops = bloops
    @last_tune_length = 0
    @length = 0

    instance_eval(&block)
  end

  def metaclass
    class << self; self; end
  end

  def metaclass_eval(&block)
    metaclass.class_eval(&block)
  end

  def sound(name, base, &block)
    sound = bloops.sound(base)

    block.call(sound)

    instance_variable_set("@#{name}", sound)

    metaclass_eval do
      define_method(name) do |notes|
        tune(sound, notes)
      end
    end
  end

  def phrase(&block)
    instance_eval(&block)
    @length += @last_tune_length
  end

  def tune sound, notes
    bloops.tune sound, ("4 " * length) + notes
    @last_tune_length = notes.split.length
  end

  def play
    bloops.play
    sleep 1 while !bloops.stopped?
  end
end

bloops = Bloops.new
bloops.tempo = 320

song = Song.new(bloops) do
  sound :hihat, Bloops::NOISE do |s|
    s.punch = 0.5
    s.sustain = 0.05
    s.decay = 0.1
  end

  sound :kick, Bloops::NOISE do |s|
    s.punch = 0.5
    s.sustain = 0.25
    s.decay = 1.0
  end

  sound :snare, Bloops::NOISE do |s|
    s.punch = 0.5
    s.sustain = 0.25
    s.decay = 0.0
  end

  sound :bass, Bloops::SAWTOOTH do |s|
    s.decay = 0.0
  end

  sound :guitar, Bloops::SINE do |s|
    s.sustain = 0.25
    s.decay = 0.2
  end

  sound :synth, Bloops::SQUARE do |s|
    s.decay = 0.0
  end

  sound :voice, Bloops::SQUARE do |s|
    s.sustain = 0.75
    s.decay = 0.0
  end

  def hihat_intro
    hihat (["e6"] * 8 * 4).join(" ")
  end

  def drum_verse
    kick  (["a2 4 4 4 a2 4 4 4"] * 4).join(" ")
    snare (["4  4 c 4 4  4 c 4"] * 4).join(" ")
  end    

  def bass_verse
    bass %{
      4 4 4 f2 f2 f2 f2 f2
      4 4 4 a1 a1 a1 a1 a1
      4 4 4 c2 c2 c2 c2 c2
      4 4 4 a1 a1 a1 a1 a1
    }
  end

  def synth_verse
    synth %{
      4 4 4 a4 a4 a4 a4 a4
      4 4 4 g4 g4 g4 g4 g4
      4 4 4 g4 g4 g4 g4 g4
      4 4 4 g4 g4 g4 g4 g4
    }

    synth %{
      4 4 4 f4 f4 f4 f4 f4
      4 4 4 e4 e4 e4 e4 e4
      4 4 4 e4 e4 e4 e4 e4
      4 4 4 e4 e4 e4 e4 e4
    }

    synth %{
      4 4 4 d4 d4 d4 d4 d4
      4 4 4 c4 c4 c4 c4 c4
      4 4 4 c4 c4 c4 c4 c4
      4 4 4 c4 c4 c4 c4 c4
    }
  end

  def intro
    phrase do
      hihat_intro
      bass_verse

      guitar (["e5"] * 8 * 4).join(" ")
      guitar (["g5"] * 8 * 4).join(" ")
    end

    phrase do
      hihat_intro
      bass_verse

      guitar (["c5"] * 8 * 4).join(" ")
      guitar (["e5"] * 8 * 4).join(" ")
    end
  end

  def verse_phrase(&block)
    phrase do
      drum_verse
      bass_verse
      synth_verse

      instance_eval(&block)
    end
  end

  def verse_instrumental
    2.times do
      verse_phrase do
      end
    end
  end

  def verse_1
    verse_phrase do
      voice %{
        4  4  4  4  g5 g5 g5 4
        c5 c5 g5 4  g5 4  c5 c5
        c5 g5 4  4  4  4  4  4
        4  4  4  4  4  4  4  4
      }     
    end

    verse_phrase do
      voice %{
        e5 4  e5 4  e5 4  e5 d5
        e5 e5 e5 4  e5 e5 g5 a5
        e5 4  4  4  4  4  4  4
        4  4  4  4  4  4  4  4
      }     
    end
  end

  intro
  verse_instrumental
  verse_1
end

song.play
