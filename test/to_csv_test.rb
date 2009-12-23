require 'test/unit'
require 'test/lib/activerecord_test_case'
require 'test/lib/load_fixtures'

class ToCsvTest < ActiveRecordTestCase
  fixtures :movies

  def setup
    ToCSV.byte_order_marker = ToCSV.locale = ToCSV.primary_key = ToCSV.timestamps = false
    @movies = Movie.all
    @people = Person.all(:order => :name)
    store_translations('en-US', 'pt-BR')
  end

  def test_simple_array
    csv = ['Alfred Hitchcock', 'Robert Mitchum', 'Lucille Ball'].to_csv
    assert_equal "Alfred Hitchcock;Robert Mitchum;Lucille Ball\n", csv
  end

  def test_matrix
    csv = [
      ['Name', 'Age'],
      ['Icaro', 22],
      ['Gabriel', 16]
    ].to_csv

    assert_equal "Name;Age\nIcaro;22\nGabriel;16\n", csv
  end

  def test_array_of_matrixes
    csv = [
      [
        ['Name', 'Alfred'],
        ['Gender', 'M']
      ],
      [
        ['Name', 'Robert'],
        ['Gender', 'M']
      ],
      [
        ['Name', 'Lucille'],
        ['Gender', 'F']
      ]
    ].to_csv

    assert_equal "Name;Gender\nAlfred;M\nRobert;M\nLucille;F\n", csv
  end

  def test_array_of_hashes
    csv = [
      {
        'Name'   => 'Icaro',
        'E-mail' => 'icaro.ldm@gmail.com'
      },
      {
        'Name'   => 'Gabriel',
        'E-mail' => 'gaby@gmail.com'
      }
    ].to_csv

    order_01 = "Name;E-mail\nIcaro;icaro.ldm@gmail.com\nGabriel;gaby@gmail.com\n"
    order_02 = "E-mail;Name\nicaro.ldm@gmail.com;Icaro\ngaby@gmail.com;Gabriel\n"


    assert order_01 == csv || order_02 == csv
  end

  def test_without_options
    assert_equal "Dvd release date;Number of discs;Studio;Subtitles;Title\nMon Dec 08 22:00:00 -0200 2008;2;Warner Home Video;English, French, Spanish;The Dark Knight\nMon Oct 22 22:00:00 -0200 2007;1;Warner Home Video;English, Spanish, French;2001 - A Space Odyssey\n", @movies.to_csv
  end

  def test_only_option
    assert_equal "Title\nThe Dark Knight\n2001 - A Space Odyssey\n", @movies.to_csv(:only => :title)
    assert_equal @movies.to_csv(:only => :title), @movies.to_csv(:only => [:title])
    assert_equal "Studio;Title\nWarner Home Video;The Dark Knight\nWarner Home Video;2001 - A Space Odyssey\n", @movies.to_csv(:only => [:title, :studio])
  end

  def test_except_option
    assert_equal "Dvd release date;Number of discs;Subtitles;Title\nMon Dec 08 22:00:00 -0200 2008;2;English, French, Spanish;The Dark Knight\nMon Oct 22 22:00:00 -0200 2007;1;English, Spanish, French;2001 - A Space Odyssey\n", @movies.to_csv(:except => :studio)
    assert_equal @movies.to_csv(:except => :studio), @movies.to_csv(:except => [:studio])
    assert_equal "Dvd release date;Number of discs;Studio\nMon Dec 08 22:00:00 -0200 2008;2;Warner Home Video\nMon Oct 22 22:00:00 -0200 2007;1;Warner Home Video\n", @movies.to_csv(:except => [:title, :subtitles])
  end

  def test_timestamps_option
   assert_equal "Created at;Number of discs\nSat Dec 12 00:00:00 -0200 2009;2\nWed Nov 11 00:00:00 -0200 2009;1\n", @movies.to_csv(:except => [:title, :subtitles, :studio, :dvd_release_date, :updated_at])
   assert_equal "Created at;Number of discs\nSat Dec 12 00:00:00 -0200 2009;2\nWed Nov 11 00:00:00 -0200 2009;1\n", @movies.to_csv(:except => [:title, :subtitles, :studio, :dvd_release_date, :updated_at], :timestamps => false)
   assert_equal "Created at;Number of discs\nSat Dec 12 00:00:00 -0200 2009;2\nWed Nov 11 00:00:00 -0200 2009;1\n", @movies.to_csv(:except => [:title, :subtitles, :studio, :dvd_release_date, :updated_at], :timestamps => true)
  end

  def test_headers_option
    assert_equal "Icaro;23\n", ['Icaro', 23].to_csv(:headers => false)
    assert_equal "Icaro;23\n", [ [:name, :age], ['Icaro', 23] ].to_csv(:headers => false)
    assert_equal "Icaro;23\n", [ [[:name, 'Icaro'], [:age, 23]] ].to_csv(:headers => false)
    assert_equal "Subtitles;Dvd release date;Number of discs;Studio;Title\nEnglish, French, Spanish;Mon Dec 08 22:00:00 -0200 2008;2;Warner Home Video;The Dark Knight\nEnglish, Spanish, French;Mon Oct 22 22:00:00 -0200 2007;1;Warner Home Video;2001 - A Space Odyssey\n", @movies.to_csv(:headers => :subtitles)
    assert_equal "Mon Dec 08 22:00:00 -0200 2008;2;Warner Home Video;English, French, Spanish;The Dark Knight\nMon Oct 22 22:00:00 -0200 2007;1;Warner Home Video;English, Spanish, French;2001 - A Space Odyssey\n", @movies.to_csv(:headers => false)
    assert_equal "Mon Dec 08 22:00:00 -0200 2008;2;Warner Home Video;English, French, Spanish;The Dark Knight\nMon Oct 22 22:00:00 -0200 2007;1;Warner Home Video;English, Spanish, French;2001 - A Space Odyssey\n", @movies.to_csv(:headers => [false])
    assert_equal "Mon Dec 08 22:00:00 -0200 2008;2;Warner Home Video;English, French, Spanish;The Dark Knight\nMon Oct 22 22:00:00 -0200 2007;1;Warner Home Video;English, Spanish, French;2001 - A Space Odyssey\n", @movies.to_csv(:headers => [])
    assert_equal "Title;Number of discs\nThe Dark Knight;2\n2001 - A Space Odyssey;1\n", @movies.to_csv(:headers => [:title, :number_of_discs], :only => [:number_of_discs, :title])
    assert_equal "Title;Number of discs\nThe Dark Knight;2\n2001 - A Space Odyssey;1\n", @movies.to_csv(:headers => [:title, :all], :only => [:number_of_discs, :title])
    assert_equal "Title;Number of discs\nThe Dark Knight;2\n2001 - A Space Odyssey;1\n", @movies.to_csv(:headers => :title, :only => [:number_of_discs, :title])
    assert_equal "Dvd release date;Number of discs;Studio;Subtitles;Title\nMon Dec 08 22:00:00 -0200 2008;2;Warner Home Video;English, French, Spanish;The Dark Knight\nMon Oct 22 22:00:00 -0200 2007;1;Warner Home Video;English, Spanish, French;2001 - A Space Odyssey\n", @movies.to_csv(:headers => :all)
    assert_equal "Dvd release date;Number of discs;Studio;Subtitles;Title\nMon Dec 08 22:00:00 -0200 2008;2;Warner Home Video;English, French, Spanish;The Dark Knight\nMon Oct 22 22:00:00 -0200 2007;1;Warner Home Video;English, Spanish, French;2001 - A Space Odyssey\n", @movies.to_csv(:headers => [:all])
    assert_equal "Dvd release date;Studio;Subtitles;Title;Number of discs\nMon Dec 08 22:00:00 -0200 2008;Warner Home Video;English, French, Spanish;The Dark Knight;2\nMon Oct 22 22:00:00 -0200 2007;Warner Home Video;English, Spanish, French;2001 - A Space Odyssey;1\n", @movies.to_csv(:headers => [:all, :subtitles, :title, :number_of_discs])
  end

  def test_locale_option
    assert_equal "Data de Lançamento do DVD;Número de Discos;Studio;Legendas;Título\nMon Dec 08 22:00:00 -0200 2008;2;Warner Home Video;English, French, Spanish;The Dark Knight\nMon Oct 22 22:00:00 -0200 2007;1;Warner Home Video;English, Spanish, French;2001 - A Space Odyssey\n", @movies.to_csv(:locale => 'pt-BR')
  end

  def test_primary_key_option
    assert_equal "Name\nGabriel\nIcaro\n", @people.to_csv
    assert_equal "Name\nGabriel\nIcaro\n", @people.to_csv(:primary_key => false)
    assert_equal "Name\nGabriel\nIcaro\n", @people.to_csv(:primary_key => nil)
    assert_equal "Cod;Name\n2;Gabriel\n1;Icaro\n", @people.to_csv(:primary_key => true)
    assert_equal "Number of discs\n2\n1\n", @movies.to_csv(:primary_key => true, :only => [:number_of_discs])
    assert_equal "Number of discs\n2\n1\n", @movies.to_csv(:only => [:number_of_discs, :id])
    assert_equal "Dvd release date;Number of discs;Studio;Subtitles;Title\nMon Dec 08 22:00:00 -0200 2008;2;Warner Home Video;English, French, Spanish;The Dark Knight\nMon Oct 22 22:00:00 -0200 2007;1;Warner Home Video;English, Spanish, French;2001 - A Space Odyssey\n", @movies.to_csv(:primary_key => true, :except => :id)
    assert_equal "Name\nGabriel\nIcaro\n", @people.to_csv(:methods => :cod)
  end

  def test_block_passed
    csv = @movies.to_csv do |csv, movie|
      csv.title = movie.title.upcase
      csv.number_of_discs = "%02d" % movie.number_of_discs
    end
    assert_equal "Dvd release date;Number of discs;Studio;Subtitles;Title\nMon Dec 08 22:00:00 -0200 2008;02;Warner Home Video;English, French, Spanish;THE DARK KNIGHT\nMon Oct 22 22:00:00 -0200 2007;01;Warner Home Video;English, Spanish, French;2001 - A SPACE ODYSSEY\n", csv
  end

  def test_default_settings
    ToCSV.byte_order_marker = true
    ToCSV.locale = 'pt-BR'
    ToCSV.primary_key = true
    ToCSV.timestamps = true
    assert_equal "\xEF\xBB\xBFCreated at;Data de Lançamento do DVD;Id;Número de Discos;Studio;Legendas;Título;Updated at\nSat Dec 12 00:00:00 -0200 2009;Mon Dec 08 22:00:00 -0200 2008;1;2;Warner Home Video;English, French, Spanish;The Dark Knight;Sat Dec 12 00:00:00 -0200 2009\n", Array(@movies.first).to_csv
  end

  private

    def store_translations(*locales)
      locale_path = File.join(File.dirname(__FILE__), 'locales')
      locales.each do |locale|
        I18n.backend.store_translations locale, YAML.load_file(File.join(locale_path, "#{ locale }.yml"))
      end
    end
end
