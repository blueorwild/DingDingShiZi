
import 'package:flutterapp/ui/home_page.dart';
import 'package:flutterapp/ui/study_page.dart';
import 'package:flutterapp/ui/text_detail_page.dart';
import 'package:flutterapp/ui/special_column.dart';
import 'package:flutterapp/ui/fallible_character_page.dart';
import 'package:flutterapp/ui/fallible_word_page.dart';
import 'package:flutterapp/ui/fallible_meaning_page.dart';
import 'package:flutterapp/ui/fallible_detail_page.dart';
import 'package:flutterapp/ui/practice_page.dart';
import 'package:flutterapp/ui/text_order_page.dart';
import 'package:flutterapp/ui/select_word_page.dart';
import 'package:flutterapp/ui/dictate_page.dart';
import 'package:flutterapp/ui/multi_text_random_page.dart';
import 'package:flutterapp/ui/single_select_word_page.dart';
import 'package:flutterapp/ui/single_select_pinyin_page.dart';


const homePage = "/a";                 // 主页

const studyPage = "/b";                // 主页->学习
const textDetailPage = "/c";           // 主页->学习->字详情

const specialColumnPage = "/d";        // 主页->专栏
const fallibleCharacterPage = "/e";    // 主页->专栏->易错字音
const fallibleWordPage = "/f";         // 主页->专栏->易错词音
const fallibleMeaningPage = "/g";      // 主页->专栏->易错语义
const fallibleDetailPage = "/h";       // 主页->专栏->易错语义/易错词音->易错详情

const practicePage = "/i";             // 主页->练习
const textOrderPage = "/j";            // 主页->练习->课文顺序
const selectWordPage = "/k";           // 主页->练习->课文顺序->选词
const dictatePage = "/l";              // 主页->练习->课文顺序->选词->听写页面
const multiTextRandomPage = "/m";      // 主页->练习->多课随机
const singleSelectWordPage = "/n";     // 主页->练习->听音选词
const singleSelectPinyinPage = "/o";   // 主页->练习->看字选音

// ignore: non_constant_identifier_names
var RoutePath = {
  "$homePage": (context) => HomePage(),
  "$studyPage": (context) => StudyPage(),
  "$textDetailPage": (context) => TextDetailPage(),
  "$specialColumnPage": (context) => SpecialColumnPage(),
  "$fallibleCharacterPage": (context) => FallibleCharacterPage(),
  "$fallibleWordPage": (context) => FallibleWordPage(),
  "$fallibleMeaningPage": (context) => FallibleMeaningPage(),
  "$fallibleDetailPage": (context) => FallibleDetailPage(),
  "$practicePage": (context) => PracticePage(),
  "$textOrderPage": (context) => TextOrderPage(),
  "$selectWordPage": (context) => SelectWordPage(),
  "$dictatePage": (context) => DictatePage(),
  "$multiTextRandomPage": (context) => MultiTextRandomPage(),
  "$singleSelectWordPage": (context) => SingleSelectWordPage(),
  "$singleSelectPinyinPage": (context) => SingleSelectPinyinPage(),
};